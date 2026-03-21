import json
import mimetypes
import os
import re
from datetime import UTC, datetime
from pathlib import Path
from uuid import uuid4

import boto3
from botocore.exceptions import ClientError

s3 = boto3.client("s3")
sqs = boto3.client("sqs")
sts = boto3.client("sts")
REGION = os.environ["AWS_REGION"]
PROJECT_NAME = os.environ.get("PROJECT_NAME", "cloudpress")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "dev")
UPLOAD_QUEUE_URL = os.environ["UPLOAD_QUEUE_URL"]
VIDEO_EXTENSIONS = {"mp4", "mov", "avi", "mkv", "webm"}
MARKDOWN_EXTENSIONS = {"md", "markdown"}


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def _safe_username(raw_user):
    safe = re.sub(r"[^a-z0-9-]+", "-", raw_user.lower()).strip("-")
    safe = re.sub(r"-{2,}", "-", safe)
    return safe or "user"


def _build_bucket_name(username):
    account_id = sts.get_caller_identity()["Account"]
    suffix = f"-{account_id}"
    prefix = f"{PROJECT_NAME}-{ENVIRONMENT}-{username}"
    max_prefix_size = 63 - len(suffix)
    return f"{prefix[:max_prefix_size].rstrip('-')}{suffix}"


def _ensure_bucket(bucket_name):
    params = {"Bucket": bucket_name}
    if REGION != "us-east-1":
        params["CreateBucketConfiguration"] = {"LocationConstraint": REGION}
    try:
        s3.create_bucket(**params)
    except ClientError as err:
        code = err.response.get("Error", {}).get("Code", "")
        if code not in ("BucketAlreadyOwnedByYou", "BucketAlreadyExists"):
            raise


def _ensure_bucket_cors(bucket_name):
    s3.put_bucket_cors(
        Bucket=bucket_name,
        CORSConfiguration={
            "CORSRules": [
                {
                    "AllowedHeaders": ["*"],
                    "AllowedMethods": ["PUT", "HEAD"],
                    "AllowedOrigins": ["*"],
                    "ExposeHeaders": ["ETag"],
                    "MaxAgeSeconds": 300,
                }
            ]
        },
    )


def _normalize_text_field(body, key, label):
    value = str(body.get(key, "")).strip()
    if not value:
        raise ValueError(f"{label} e obrigatorio.")
    return value


def _normalize_is_sponsored(body):
    value = body.get("isSponsored")
    if isinstance(value, bool):
        return value
    raise ValueError("isSponsored deve ser booleano.")


def _infer_content_category(filename):
    extension = Path(filename).suffix.lower().lstrip(".")
    if extension in MARKDOWN_EXTENSIONS:
        return extension, "markdown"
    if extension in VIDEO_EXTENSIONS:
        return extension, "video"
    raise ValueError("Formato de arquivo nao suportado.")


def _default_content_type(filename, provided_content_type):
    normalized_content_type = (provided_content_type or "").strip()
    if normalized_content_type:
        return normalized_content_type
    guessed_content_type, _ = mimetypes.guess_type(filename)
    return guessed_content_type or "application/octet-stream"


def _enqueue_upload(payload):
    sqs.send_message(QueueUrl=UPLOAD_QUEUE_URL, MessageBody=json.dumps(payload))


def handler(event, context):
    del context
    claims = (
        event.get("requestContext", {})
        .get("authorizer", {})
        .get("jwt", {})
        .get("claims", {})
    )
    user_login = (
        claims.get("email") or claims.get("cognito:username") or claims.get("username")
    )
    user_sub = claims.get("sub")
    if not user_login:
        return _response(401, {"message": "Usuário não autenticado."})
    if not user_sub:
        return _response(401, {"message": "Identificador do usuário não encontrado."})

    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"message": "Payload inválido."})

    filename = str(body.get("filename", "")).strip()
    if not filename:
        return _response(400, {"message": "filename e obrigatorio."})

    try:
        title = _normalize_text_field(body, "title", "title")
        description = _normalize_text_field(body, "description", "description")
        is_sponsored = _normalize_is_sponsored(body)
        file_extension, content_category = _infer_content_category(filename)
    except ValueError as err:
        return _response(400, {"message": str(err)})

    content_type = _default_content_type(filename, body.get("contentType"))

    safe_user = _safe_username(user_login)
    bucket_name = _build_bucket_name(safe_user)
    object_key = f"uploads/{filename}"
    content_id = str(uuid4())
    created_at = datetime.now(UTC).isoformat()
    queue_payload = {
        "contentId": content_id,
        "userSub": user_sub,
        "userLogin": user_login,
        "title": title,
        "description": description,
        "filename": filename,
        "fileExtension": file_extension,
        "contentType": content_type,
        "contentCategory": content_category,
        "isSponsored": is_sponsored,
        "sponsoredStatus": "SPONSORED" if is_sponsored else "ORGANIC",
        "bucket": bucket_name,
        "key": object_key,
        "createdAt": created_at,
        "status": "PENDING_UPLOAD",
    }

    try:
        _ensure_bucket(bucket_name)
        _ensure_bucket_cors(bucket_name)
        upload_url = s3.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": bucket_name,
                "Key": object_key,
                "ContentType": content_type,
            },
            ExpiresIn=300,
        )
        _enqueue_upload(queue_payload)
    except Exception:
        return _response(500, {"message": "Falha ao preparar upload."})

    return _response(
        200,
        {
            "message": "URL de upload gerada com sucesso.",
            "contentId": content_id,
            "contentCategory": content_category,
            "bucket": bucket_name,
            "key": object_key,
            "uploadUrl": upload_url,
            "expiresIn": 300,
        },
    )

import json
import os
import re

import boto3
from botocore.exceptions import ClientError

s3 = boto3.client("s3")
sts = boto3.client("sts")
REGION = os.environ["AWS_REGION"]
PROJECT_NAME = os.environ.get("PROJECT_NAME", "cloudpress")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "dev")


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
    if not user_login:
        return _response(401, {"message": "Usuário não autenticado."})

    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"message": "Payload inválido."})

    filename = body.get("filename", "").strip()
    content_type = body.get("contentType", "text/markdown").strip() or "text/markdown"
    if not filename:
        return _response(400, {"message": "filename é obrigatório."})
    if not filename.lower().endswith(".md"):
        return _response(400, {"message": "Somente arquivos .md são permitidos."})

    safe_user = _safe_username(user_login)
    bucket_name = _build_bucket_name(safe_user)
    object_key = f"uploads/{filename}"

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
    except Exception:
        return _response(500, {"message": "Falha ao gerar URL de upload."})

    return _response(
        200,
        {
            "message": "URL de upload gerada com sucesso.",
            "bucket": bucket_name,
            "key": object_key,
            "uploadUrl": upload_url,
            "expiresIn": 300,
        },
    )

#!/usr/bin/env bash
set -e

PROJECT_NAME="cloudpress"
ENVIRONMENT="dev"
REGION="us-east-1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAMBDA_STACK_NAME="${PROJECT_NAME}-${ENVIRONMENT}-lambda"
API_BINDING_STACK_NAME="${PROJECT_NAME}-${ENVIRONMENT}-api-lambda-binding"
LAMBDA_TEMPLATE_FILE="$ROOT_DIR/cloudpress_infra/cloudformation/templates/lambda.yaml"
API_BINDING_TEMPLATE_FILE="$ROOT_DIR/cloudpress_infra/cloudformation/templates/api-lambda-binding.yaml"
LAMBDA_SOURCE_DIR="$ROOT_DIR/cloudpress_backend/lambdas/upload_markdown"
LAMBDA_ZIP_FILE="/tmp/${PROJECT_NAME}-${ENVIRONMENT}-upload-markdown-lambda.zip"

echo "📤 Criando/Atualizando stack Upload API..."

ARTIFACT_BUCKET=$(aws cloudformation describe-stacks \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-s3-lambda \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" \
  --output text)

if [[ -z "$ARTIFACT_BUCKET" || "$ARTIFACT_BUCKET" == "None" ]]; then
  echo "❌ Não foi possível obter o bucket da stack S3"
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "❌ comando 'zip' não encontrado. Instale o zip para continuar."
  exit 1
fi

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "❌ comando 'sha256sum' não encontrado. Instale o coreutils para continuar."
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "❌ comando 'openssl' não encontrado. Instale o openssl para continuar."
  exit 1
fi

GIT_SHA=$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || echo "nogit")
ARTIFACT_TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
LAMBDA_S3_KEY="lambda-artifacts/upload-markdown/${ARTIFACT_TIMESTAMP}-${GIT_SHA}.zip"

echo "🧱 Empacotando Lambda de upload..."
rm -f "$LAMBDA_ZIP_FILE"
(
  cd "$LAMBDA_SOURCE_DIR"
  zip -rq "$LAMBDA_ZIP_FILE" .
)
echo "✅ Zip gerado em: $LAMBDA_ZIP_FILE"

LAMBDA_CODE_HASH=$(openssl dgst -sha256 -binary "$LAMBDA_ZIP_FILE" | openssl base64 -A)
echo "🔐 Hash do artefato: $LAMBDA_CODE_HASH"

echo "☁️ Enviando artefato Lambda para S3..."
aws s3 cp "$LAMBDA_ZIP_FILE" "s3://${ARTIFACT_BUCKET}/${LAMBDA_S3_KEY}" --region $REGION

aws s3api head-object \
  --bucket "$ARTIFACT_BUCKET" \
  --key "$LAMBDA_S3_KEY" \
  --region "$REGION" >/dev/null

echo "✅ Artefato disponível em s3://${ARTIFACT_BUCKET}/${LAMBDA_S3_KEY}"

echo "🚀 Atualizando stack da Lambda com versionamento e blue/green..."
aws cloudformation deploy \
  --region "$REGION" \
  --stack-name "$LAMBDA_STACK_NAME" \
  --template-file "$LAMBDA_TEMPLATE_FILE" \
  --parameter-overrides \
    ProjectName="$PROJECT_NAME" \
    Environment="$ENVIRONMENT" \
    LambdaCodeS3Bucket="$ARTIFACT_BUCKET" \
    LambdaCodeS3Key="$LAMBDA_S3_KEY" \
    LambdaCodeHash="$LAMBDA_CODE_HASH" \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset

echo "🔗 Garantindo binding do API Gateway com o alias live..."
aws cloudformation deploy \
  --region "$REGION" \
  --stack-name "$API_BINDING_STACK_NAME" \
  --template-file "$API_BINDING_TEMPLATE_FILE" \
  --parameter-overrides \
    ProjectName="$PROJECT_NAME" \
    Environment="$ENVIRONMENT" \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset

echo "✅ Deploy da Lambda concluído com alias estável e traffic shifting via CodeDeploy"

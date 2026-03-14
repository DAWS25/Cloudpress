#!/usr/bin/env bash
set -e

PROJECT_NAME="cloudpress"
ENVIRONMENT="dev"
REGION="us-east-1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LAMBDA_SOURCE_DIR="$ROOT_DIR/cloudpress_backend/lambdas/upload_markdown"
LAMBDA_ZIP_FILE="/tmp/${PROJECT_NAME}-${ENVIRONMENT}-upload-markdown-lambda.zip"

echo "📤 Criando/Atualizando stack Upload API..."

if ! command -v zip >/dev/null 2>&1; then
  echo "❌ comando 'zip' não encontrado. Instale o zip para continuar."
  exit 1
fi

ARTIFACT_BUCKET=$(aws cloudformation describe-stacks \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-s3-lambda \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" \
  --output text)

if [[ -z "$ARTIFACT_BUCKET" || "$ARTIFACT_BUCKET" == "None" ]]; then
  echo "❌ Não foi possível obter o bucket da stack S3"
  exit 1
fi

LAMBDA_S3_KEY="lambda-artifacts/upload-markdown-lambda.zip"

echo "🧱 Empacotando Lambda de upload..."
rm -f "$LAMBDA_ZIP_FILE"
(
  cd "$LAMBDA_SOURCE_DIR"
  zip -rq "$LAMBDA_ZIP_FILE" .
)
echo "✅ Zip gerado em: $LAMBDA_ZIP_FILE"

echo "☁️ Enviando artefato Lambda para S3..."
aws s3 cp "$LAMBDA_ZIP_FILE" "s3://${ARTIFACT_BUCKET}/${LAMBDA_S3_KEY}" --region $REGION

aws s3api head-object \
  --bucket "$ARTIFACT_BUCKET" \
  --key "$LAMBDA_S3_KEY" \
  --region "$REGION" >/dev/null

echo "✅ Artefato disponível em s3://${ARTIFACT_BUCKET}/${LAMBDA_S3_KEY}"

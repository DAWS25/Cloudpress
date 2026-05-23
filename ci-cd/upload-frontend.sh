#!/usr/bin/env bash
set -e

PROJECT_NAME="cloudpress"
ENVIRONMENT="dev"
REGION="us-east-1"

FRONTEND_DIR="../cloudpress_frontend/dist"

BUCKET_NAME="${PROJECT_NAME}-${ENVIRONMENT}-frontend"

echo "📦 Iniciando upload do frontend para S3"
echo "Bucket: $BUCKET_NAME"
echo "Região: $REGION"

# Verifica se o build existe
if [ ! -d "$FRONTEND_DIR" ]; then
  echo "❌ Diretório dist não encontrado. Execute npm run build antes."
  exit 1
fi

# Upload dos arquivos
aws s3 sync $FRONTEND_DIR s3://$BUCKET_NAME \
  --region $REGION \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "index.html"

# Upload do index.html sem cache
aws s3 cp $FRONTEND_DIR/index.html s3://$BUCKET_NAME/index.html \
  --region $REGION \
  --cache-control "no-cache, no-store, must-revalidate"

echo "✅ Upload concluído com sucesso"

#!/usr/bin/env bash
set -e

PROJECT_NAME="cloudpress"
ENVIRONMENT="dev"
REGION="us-east-1"

echo "🚀 Deploy CloudPress - Ambiente: $ENVIRONMENT"

# ===============================
# Stack S3
# ===============================
echo "📦 Criando/Atualizando stack S3..."

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-s3 \
  --template-file ../cloudpress_infra/cloudformation/templates/s3.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack S3 finalizada"

# ===============================
# Stack CloudFront
# ===============================
echo "🌍 Criando/Atualizando stack CloudFront..."

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-cloudfront \
  --template-file ../cloudpress_infra/cloudformation/templates/cloudfront.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack CloudFront finalizada"

echo "🎉 Deploy concluído com sucesso"

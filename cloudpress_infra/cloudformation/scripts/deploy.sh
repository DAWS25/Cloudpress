#!/usr/bin/env bash
set -e

PROJECT_NAME="cloudpress"
ENVIRONMENT="dev"
REGION="us-east-1"
LAMBDA_SOURCE_DIR="../cloudpress_backend/lambdas/upload_markdown"
LAMBDA_ZIP_FILE="/tmp/${PROJECT_NAME}-${ENVIRONMENT}-upload-markdown.zip"
UPLOAD_QUEUE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-upload-metadata-queue"
UPLOAD_DLQ_NAME="${PROJECT_NAME}-${ENVIRONMENT}-upload-metadata-dlq"
UPLOAD_TABLE_NAME="${PROJECT_NAME}-${ENVIRONMENT}-upload-metadata"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

echo "🚀 Deploy CloudPress - Ambiente: $ENVIRONMENT"

# ===============================
# Stack S3
# ===============================
echo "📦 Criando/Atualizando stack S3..."

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-s3 \
  --template-file ${TEMPLATE_DIR}/s3.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
    ResourcePrefix=frontend \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-s3-lambda \
  --template-file ${TEMPLATE_DIR}/s3.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
    ResourcePrefix=lambda \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack S3 finalizada"

# ===============================
# Stack CloudFront
# ===============================
echo "🌍 Criando/Atualizando stack CloudFront..."

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-cloudfront \
  --template-file ${TEMPLATE_DIR}/cloudfront.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
    ResourcePrefix=frontend \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack CloudFront finalizada"

# ===============================
# Stack Cognito
# ===============================
echo "🔐 Criando/Atualizando stack Cognito..."

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-cognito \
  --template-file ${TEMPLATE_DIR}/cognito.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack Cognito finalizada"

# ===============================
# Stack SQS
# ===============================
echo "📨 Criando/Atualizando stack SQS..."

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-sqs \
  --template-file ${TEMPLATE_DIR}/sqs.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
    QueueName=$UPLOAD_QUEUE_NAME \
    DeadLetterQueueName=$UPLOAD_DLQ_NAME \
    VisibilityTimeout=60 \
    MessageRetentionSeconds=345600 \
    ReceiveMessageWaitTimeSeconds=20 \
    DelaySeconds=0 \
    MaxReceiveCount=5 \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack SQS finalizada"

# ===============================
# Stack DynamoDB
# ===============================
echo "🗄️ Criando/Atualizando stack DynamoDB..."

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-dynamodb \
  --template-file ${TEMPLATE_DIR}/dynamodb.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
    TableName=$UPLOAD_TABLE_NAME \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack DynamoDB finalizada"

# ===============================
# Stack Lambda
# ===============================
echo "📤 Criando/Atualizando stack Lambda ..."

ARTIFACT_BUCKET=$(aws cloudformation describe-stacks \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-s3-lambda \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" \
  --output text)


LAMBDA_S3_KEY="lambda-artifacts/upload-markdown-lambda.zip"

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-lambda \
  --template-file ${TEMPLATE_DIR}/lambda.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
    LambdaCodeS3Bucket=$ARTIFACT_BUCKET \
    LambdaCodeS3Key=$LAMBDA_S3_KEY \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack Lambda finalizada"

# ===============================
# Stack Api Gateway
# ===============================
echo "📤 Criando/Atualizando stack API Gateway ..."

CLOUDFRONT_DOMAIN=$(aws cloudformation describe-stacks \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-cloudfront \
  --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDomainName'].OutputValue" \
  --output text || true)

if [[ -n "$CLOUDFRONT_DOMAIN" && "$CLOUDFRONT_DOMAIN" != "None" ]]; then
  ALLOWED_ORIGIN="https://${CLOUDFRONT_DOMAIN}"
else
  ALLOWED_ORIGIN="*"
fi

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-api-gateway \
  --template-file ${TEMPLATE_DIR}/api-gateway.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
    AllowedOrigin=$ALLOWED_ORIGIN \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack API Gateway finalizada"

# ===============================
# Stack API Lambda Binding
# ===============================
echo "🔗 Criando/Atualizando stack API Lambda Binding ..."

aws cloudformation deploy \
  --region $REGION \
  --stack-name ${PROJECT_NAME}-${ENVIRONMENT}-api-lambda-binding \
  --template-file ${TEMPLATE_DIR}/api-lambda-binding.yaml \
  --parameter-overrides \
    ProjectName=$PROJECT_NAME \
    Environment=$ENVIRONMENT \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Stack API Lambda Binding finalizada"

echo "🎉 Deploy concluído com sucesso"

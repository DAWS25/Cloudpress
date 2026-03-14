#!/usr/bin/env bash
set -e

# Diretório onde o script está localizado
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

echo "🔍 Validando templates CloudFormation..."

TEMPLATES=(
  "$TEMPLATE_DIR/s3.yaml"
  "$TEMPLATE_DIR/cloudfront.yaml"
  "$TEMPLATE_DIR/cognito.yaml"
  "$TEMPLATE_DIR/lambda.yaml"
  "$TEMPLATE_DIR/api-gateway.yaml"
  "$TEMPLATE_DIR/api-lambda-binding.yaml"
)

for template in "${TEMPLATES[@]}"; do
  echo "Validando $template"
  aws cloudformation validate-template \
    --template-body file://$template
done

echo "✅ Todos os templates são válidos"

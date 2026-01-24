#!/usr/bin/env bash
set -e

echo "🔍 Validando templates CloudFormation..."

TEMPLATES=(
  "../cloudpress_infra/cloudformation/templates/s3.yaml"
  "../cloudpress_infra/cloudformation/templates/cloudfront.yaml"
)

for template in "${TEMPLATES[@]}"; do
  echo "Validando $template"
  aws cloudformation validate-template \
    --template-body file://$template
done

echo "✅ Todos os templates são válidos"
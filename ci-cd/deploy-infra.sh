#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATE_SCRIPT="$ROOT_DIR/cloudpress_infra/cloudformation/scripts/validate.sh"
DEPLOY_SCRIPT="$ROOT_DIR/cloudpress_infra/cloudformation/scripts/deploy.sh"

echo "🔍 Etapa 1: validação da infraestrutura"
bash "$VALIDATE_SCRIPT"

echo "🚀 Etapa 2: deploy da infraestrutura"
bash "$DEPLOY_SCRIPT"

echo "✅ Pipeline de infra concluído"

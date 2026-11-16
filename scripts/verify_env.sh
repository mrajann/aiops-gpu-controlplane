#!/usr/bin/env bash
set -euo pipefail

echo "==> Validating control plane pre-requisites..."

if [[ ! -f .env ]]; then
  echo "Error: .env file missing. Copy .env.example to .env first."
  exit 1
fi

# Load env variables safely
set -a
source .env
set +a

MISSING=0
if [[ -z "${LITELLM_MASTER_KEY:-}" ]]; then
  echo "❌ LITELLM_MASTER_KEY is not set."
  MISSING=1
else
  echo "✅ LITELLM_MASTER_KEY is configured."
fi

if [[ -z "${VLLM_API_KEY:-}" ]]; then
  echo "⚠️  VLLM_API_KEY is empty (will rely on gateway defaults)."
fi

if [[ $MISSING -eq 1 ]]; then
  echo "Please fix missing environment variables in .env before proceeding."
  exit 1
fi

echo "==> Environment validation complete."
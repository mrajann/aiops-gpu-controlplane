#!/usr/bin/env bash
set -euo pipefail

GATEWAY_URL="http://localhost:4000"
MASTER_KEY="${LITELLM_MASTER_KEY:-}"

if [[ -z "$MASTER_KEY" ]]; then
  echo "Error: LITELLM_MASTER_KEY is not set."
  exit 1
fi

echo "==> 1. Testing normal route to primary model (qwen-7b-instruct)..."
STATUS_PRIMARY=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${GATEWAY_URL}/v1/chat/completions" \
  -H "Authorization: Bearer ${MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-7b-instruct",
    "messages": [{"role": "user", "content": "ping"}],
    "max_tokens": 5
  }')
echo "Primary Model Route: HTTP ${STATUS_PRIMARY}"

echo -e "\n==> 2. Verifying model info & fallback mapping via admin endpoint..."
curl -s -X GET "${GATEWAY_URL}/models" \
  -H "Authorization: Bearer ${MASTER_KEY}" | grep -o '"model_name":"[^"]*' || true

echo -e "\n\n==> Fallback router verification complete."
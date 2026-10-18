#!/usr/bin/env bash
set -euo pipefail

GATEWAY_URL="http://localhost:4000"
MASTER_KEY="${LITELLM_MASTER_KEY:-}"

if [[ -z "$MASTER_KEY" ]]; then
  echo "Error: LITELLM_MASTER_KEY is not set in environment."
  exit 1
fi

echo "==> 1. Generating restricted virtual key (3 RPM limit, \$2.00 budget)..."
RESPONSE=$(curl -s -X POST "${GATEWAY_URL}/key/generate" \
  -H "Authorization: Bearer ${MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "models": ["qwen-7b-instruct"],
    "duration": "12h",
    "max_budget": 2.0,
    "rpm_limit": 3,
    "metadata": {"team": "dev-sandbox", "owner": "vibe-coder"}
  }')

VIRTUAL_KEY=$(echo "$RESPONSE" | grep -o '"key":"[^"]*' | cut -d'"' -f4 || true)

if [[ -z "$VIRTUAL_KEY" ]]; then
  echo "Failed to generate key. Gateway response:"
  echo "$RESPONSE"
  exit 1
fi

echo "Generated Key: ${VIRTUAL_KEY}"

echo -e "\n==> 2. Sending burst requests to trigger 429 Rate Limit..."
for i in {1..5}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${GATEWAY_URL}/v1/chat/completions" \
    -H "Authorization: Bearer ${VIRTUAL_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
      "model": "qwen-7b-instruct",
      "messages": [{"role": "user", "content": "ping"}],
      "max_tokens": 5
    }')
  echo "Request #${i}: HTTP Status ${STATUS}"
done

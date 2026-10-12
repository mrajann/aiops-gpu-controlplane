#!/usr/bin/env bash
# ==============================================================================
# Script Name: vllm-entrypoint.sh
# Description: Secure startup script for remote GPU inference worker running vLLM.
# Security: Enforces API key token validation and allocates safe GPU memory.
# ==============================================================================

set -uo pipefail

# Security check: Ensure VLLM_API_KEY is explicitly set to prevent unauthenticated exposure
if [ -z "${VLLM_API_KEY:-}" ]; then
    echo "[ERROR] Security Violation: VLLM_API_KEY environment variable is unset or empty."
    echo "[ERROR] Refusing to start vLLM without an authentication token."
    exit 1
fi

MODEL_NAME="${MODEL_NAME:-Qwen/Qwen2.5-7B-Instruct}"
PORT="${PORT:-8000}"
GPU_MEMORY_UTILIZATION="${GPU_MEMORY_UTILIZATION:-0.90}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-4096}"

echo "[INFO] Starting vLLM inference engine for model: ${MODEL_NAME}"
echo "[INFO] Enforcing security API key validation..."

# Execute vLLM production container server
exec python3 -m vllm.entrypoints.openai.api_server \
    --model "${MODEL_NAME}" \
    --port "${PORT}" \
    --api-key "${VLLM_API_KEY}" \
    --gpu-memory-utilization "${GPU_MEMORY_UTILIZATION}" \
    --max-model-len "${MAX_MODEL_LEN}"
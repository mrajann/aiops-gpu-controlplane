# Runbook: Remote GPU Pod Deployment & Security Hardening

## 1. Overview
This runbook details the procedure for provisioning a remote GPU inference worker (RunPod NVIDIA RTX 3090 / A5000 24GB VRAM) and establishing a secure communication tunnel back to the local Mac control plane[cite: 1].

## 2. Security Best Practices
* **No Public API Exposure:** Never expose port `8000` directly to the public web (`0.0.0.0/0`).
* **Token Authentication:** Always supply a secure `VLLM_API_KEY` to prevent unauthorized model queries.
* **Encrypted Transport:** All communication between the local LiteLLM gateway and the remote vLLM instance must occur over secure SSH port-forwarding tunnels.

## 3. Provisioning Steps
1. Deploy an NVIDIA RTX 3090 or A5000 pod on RunPod using the official CUDA template[cite: 1].
2. Upload your SSH public key to RunPod to secure management access.
3. Set your environment variable on the pod:
   ```bash
   export VLLM_API_KEY="your-secure-vllm-token"
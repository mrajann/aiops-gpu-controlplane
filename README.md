# AIOps GPU Control Plane

A secure, scalable, and resilient hybrid AIOps control plane designed to govern, observe, and route GPU-accelerated LLM inference workloads. It bridges decentralized compute infrastructure (such as remote RunPod vLLM workers) with internal engineering applications through a centralized, database-backed gateway.

---

## 🏛️ System Architecture Flow

```
+---------------------------------------------------------------------------------+
|                        Client Applications & SDKs                               |
|       (FastAPI Microservices, Streamlit Dashboards, ControlPlaneClient)         |
+---------------------------------------------------------------------------------+
                                         |
                                    HTTPS / Bearer
                                         v
+---------------------------------------------------------------------------------+
|                          LiteLLM Gateway Router (Port 4000)                     |
|  - Virtual API Key Validation    - Usage-Based Routing & Fallback Chains        |
|  - Rate Limiting (RPM/TPM)       - Budget Caps & Spend Tracking                 |
+---------------------------------------------------------------------------------+
         |                                       |                        |
         | Writes State / Metrics                | Scrapes Metrics        | Proxies Inference
         v                                       v                        v
+------------------+                    +------------------+    +-------------------------+
|    PostgreSQL    |                    |    Prometheus    |    |       Grafana           |
|  (Virtual Keys,  |                    |  (Scrape Target) |    |  (Observability Dash)   |
|   Spend Logs)    |                    +------------------+    +-------------------------+
+------------------+                                                           
                                                                               |
                                                                        SSH Tunnel (-L)
                                                                               |
                                                                               v
                                                        +---------------------------------+
                                                        |      RunPod vLLM GPU Worker     |
                                                        |     (Qwen/Qwen2.5-7B-Instruct)  |
                                                        +---------------------------------+
```

---

## 🛠️ Core Stack & Components

1. **LiteLLM Gateway (`aiops-litellm-gateway`)**: Centralized proxy handling virtual keys, budget enforcement, usage-based routing, and automated failovers.
2. **PostgreSQL State Backend (`aiops-postgres-db`)**: Secure, persistent relational database storing virtual API tokens (`LiteLLM_VerificationToken`) and granular inference metrics (`LiteLLM_SpendLogs`).
3. **Prometheus & Grafana**: Observability and telemetry stack tracking request latencies, token throughput, and system health.
4. **Client SDK (`ControlPlaneClient`)**: Python wrapper supporting synchronous chat completions and real-time streaming with built-in error handling for rate limits and auth failures.

---

## 🚀 Quick Start Guide

### 1. Environment Configuration
Copy the environment template and populate your secrets:
```bash
cp .env.example .env
```
Ensure `LITELLM_MASTER_KEY` and `VLLM_API_KEY` are configured in your `.env` file.

### 2. Launch Infrastructure Stack
Start the containerized control plane services:
```bash
cd deployments
docker compose up -d
```

### 3. Establish RunPod SSH Tunnel
Open a secure port-forwarded tunnel to your remote RunPod vLLM worker:
```bash
ssh -N -f -L 8000:localhost:8000 root@<RUNPOD_PUBLIC_IP> -p <RUNPOD_SSH_PORT> -i ~/.ssh/id_ed25519
```

### 4. Run Guardrail & Rate-Limit Tests
Validate that velocity caps and budget enforcement are active:
```bash
./scripts/test_guardrails.sh
```

---

## 📂 Repository Structure

```text
├── config/
│   ├── litellm/config.yaml         # Gateway routing, guardrails, and model definitions
│   └── prometheus/prometheus.yml   # Telemetry scrape targets
├── deployments/
│   └── docker-compose.yml          # Core container infrastructure definition
├── sdk/
│   └── gateway_client.py           # Standardized Python ControlPlaneClient SDK
├── examples/
│   └── demo_client.py              # Synchronous and streaming inference consumer demo
├── scripts/
│   ├── test_guardrails.sh          # Automated rate-limit and budget test utility
│   ├── test_failover.sh            # Fallback routing and resilience verification
│   └── verify_env.sh               # Pre-flight environment check utility
├── requirements.txt                # Python client dependencies
└── README.md
```
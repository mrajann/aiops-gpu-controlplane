#!/usr/bin/env python3
"""
Example consumer application demonstrating both standard and streaming
calls through the AIOps LiteLLM gateway.
"""

import os
import sys
from pathlib import Path

# Ensure sdk module is in python path
sys.path.append(str(Path(__file__).resolve().parent.parent))

from sdk.gateway_client import ControlPlaneClient


def main():
    gateway_url = os.getenv("LITELLM_GATEWAY_URL", "http://localhost:4000/v1")
    api_key = os.getenv("LITELLM_VIRTUAL_KEY") or os.getenv("LITELLM_MASTER_KEY", "sk-test")

    print(f"Connecting to Control Plane Gateway at: {gateway_url}")
    client = ControlPlaneClient(base_url=gateway_url, api_key=api_key)

    messages = [
        {"role": "system", "content": "You are a specialized site reliability and AIOps engineer."},
        {"role": "user", "content": "Explain what a rate limit 429 means in one sentence."},
    ]

    print("\n--- 1. Synchronous Inference Test ---")
    try:
        response = client.chat(messages=messages, max_tokens=60)
        content = response.choices[0].message.content
        tokens = response.usage.total_tokens if response.usage else "N/A"
        print(f"Response:\n{content}\n(Tokens used: {tokens})")
    except Exception as e:
        print(f"Error during standard call: {e}")

    print("\n--- 2. Real-Time Streaming Test ---")
    try:
        print("Stream Output: ", end="", flush=True)
        for token in client.stream_chat(messages=messages, max_tokens=60):
            print(token, end="", flush=True)
        print()
    except Exception as e:
        print(f"\nError during streaming call: {e}")


if __name__ == "__main__":
    main()
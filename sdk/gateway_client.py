"""
AIOps Control Plane Gateway Client.
Standardized wrapper for LiteLLM virtual token authentication, 
streaming completions, and structured rate-limit/budget handling.
"""

from typing import Generator, Optional, Dict, Any, List
import os
from openai import OpenAI, APIError, RateLimitError, AuthenticationError


class ControlPlaneClient:
    def __init__(
        self,
        base_url: str = "http://localhost:4000/v1",
        api_key: Optional[str] = None,
        default_model: str = "qwen-7b-instruct",
    ):
        self.base_url = os.getenv("LITELLM_GATEWAY_URL", base_url)
        self.api_key = api_key or os.getenv("LITELLM_VIRTUAL_KEY") or os.getenv("LITELLM_MASTER_KEY")
        
        if not self.api_key:
            raise ValueError("An API key (virtual key or master key) must be provided.")

        self.default_model = default_model
        self._client = OpenAI(
            base_url=self.base_url,
            api_key=self.api_key,
        )

    def chat(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        max_tokens: int = 512,
        temperature: float = 0.7,
        stream: bool = False,
    ) -> Any:
        target_model = model or self.default_model
        try:
            response = self._client.chat.completions.create(
                model=target_model,
                messages=messages,
                max_tokens=max_tokens,
                temperature=temperature,
                stream=stream,
            )
            return response
        except RateLimitError as e:
            raise RuntimeError(f"[429] Rate limit or budget cap exceeded: {e.message}") from e
        except AuthenticationError as e:
            raise RuntimeError(f"[401] Gateway authentication failure: {e.message}") from e
        except APIError as e:
            raise RuntimeError(f"[{e.status_code}] Gateway routing error: {e.message}") from e

    def stream_chat(
        self,
        messages: List[Dict[str, str]],
        model: Optional[str] = None,
        max_tokens: int = 512,
    ) -> Generator[str, None, None]:
        stream_resp = self.chat(
            messages=messages,
            model=model,
            max_tokens=max_tokens,
            stream=True,
        )
        for chunk in stream_resp:
            content = chunk.choices[0].delta.content or ""
            if content:
                yield content
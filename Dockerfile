FROM runpod/worker-comfyui:5.4.1-base

# --- Build arg & env for Civitai ---
ARG CIVITAI_TOKEN
# ENV CIVITAI_TOKEN=${CIVITAI_TOKEN}

# Instalar curl (necesario para bajar LoRAs desde Civitai)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# --- Custom nodes ---
RUN comfy-node-install comfyui_controlnet_aux \
    https://github.com/kadirnar/ComfyUI-YOLO.git

# --- SDXL base (checkpoint) ---
RUN comfy model download \
  --url https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors \
  --relative-path models/checkpoints \
  --filename sd_xl_base_1.0.safetensors

# --- ControlNet (Union SDXL) ---
RUN comfy model download \
  --url https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors \
  --relative-path models/controlnet \
  --filename controlnet-union-sdxl-1.safetensors

# --- LoRAs from Civitai (API key + retries + validation) ---
RUN mkdir -p /comfyui/models/loras && set -e; \
  curl -L --fail --retry 5 --retry-connrefused \
    -H "X-API-Key: ${CIVITAI_TOKEN}" \
    -o /comfyui/models/loras/xsarchitectural-7.safetensors \
    "https://civitai.com/api/download/models/30384?type=Model&format=SafeTensor" && \
  python - <<'PY'
from safetensors.torch import safe_open
p="/comfyui/models/loras/xsarchitectural-7.safetensors"
with safe_open(p, framework="pt") as f: print("OK xsarchitectural-7", len(f.keys()))
PY

RUN set -e; \
  curl -L --fail --retry 5 --retry-connrefused \
    -H "X-API-Key: ${CIVITAI_TOKEN}" \
    -o /comfyui/models/loras/Interior-Design-Universal_SDXL.safetensors \
    "https://civitai.com/api/download/models/551510?type=Model&format=SafeTensor" && \
  python - <<'PY'
from safetensors.torch import safe_open
p="/comfyui/models/loras/Interior-Design-Universal_SDXL.safetensors"
with safe_open(p, framework="pt") as f: print("OK Interior-Design-Universal", len(f.keys()))
PY

RUN set -e; \
  curl -L --fail --retry 5 --retry-connrefused \
    -H "X-API-Key: ${CIVITAI_TOKEN}" \
    -o /comfyui/models/loras/DetailTweaker_xl.safetensors \
    "https://civitai.com/api/download/models/135867?type=Model&format=SafeTensor" && \
  python - <<'PY'
from safetensors.torch import safe_open
p="/comfyui/models/loras/DetailTweaker_xl.safetensors"
with safe_open(p, framework="pt") as f: print("OK DetailTweaker_xl", len(f.keys()))
PY

# --- Upscale model ---
RUN comfy model download \
  --url https://huggingface.co/Shandypur/ESRGAN-4x-UltraSharp/resolve/main/4x-UltraSharp.pth \
  --relative-path models/upscale_models \
  --filename 4x-UltraSharp.pth

# --- Input dir ---
RUN mkdir -p /comfyui/input




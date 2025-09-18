FROM runpod/worker-comfyui:5.4.1-base

# Instalar nodos personalizados necesarios
RUN comfy-node-install comfyui_controlnet_aux comfy-yolo comfy-core

# Modelo base SDXL
RUN comfy model download --url https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors --relative-path models/checkpoints --filename sd_xl_base_1.0.safetensors

# Modelo ControlNet (para detección de bordes/estructura)
RUN comfy model download --url https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors --relative-path models/controlnet --filename controlnet-union-sdxl-1.safetensors

# Los 3 LoRAs específicos para tu workflow
RUN comfy model download --url https://civitai.com/api/download/models/30384 --relative-path models/loras --filename xsarchitectural-7.safetensors
RUN comfy model download --url https://civitai.com/api/download/models/551510 --relative-path models/loras --filename Interior-Design-Universal_SDXL.safetensors
RUN comfy model download --url https://civitai.com/api/download/models/135867 --relative-path models/loras --filename DetailTweaker_xl.safetensors

# Modelo de upscale
RUN comfy model download --url https://huggingface.co/Shandypur/ESRGAN-4x-UltraSharp/resolve/main/4x-UltraSharp.pth --relative-path models/upscale_models --filename 4x-UltraSharp.pth

# Crear directorio para imágenes de entrada

RUN mkdir -p /comfyui/input

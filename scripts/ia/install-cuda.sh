#!/bin/bash
# DevForge - CUDA Toolkit Installer

echo "🔧 DevForge: Instalando CUDA Toolkit 12.x..."

# Verificar NVIDIA GPU
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ NVIDIA GPU não detectada. Instalando drivers NVIDIA..."
    sudo apt install -y nvidia-driver-535 nvidia-utils-535
fi

# Adicionar repositório CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update

# Instalar CUDA
sudo apt install -y cuda-toolkit-12 cudnn-cuda-12

# Configurar PATH
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

echo "✅ CUDA Toolkit instalado!"
nvidia-smi
nvcc --version
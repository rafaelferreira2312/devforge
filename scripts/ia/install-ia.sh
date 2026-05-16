#!/bin/bash
# DevForge - IA/ML Stack Installer for Linux/macOS
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/ia/install-ia.sh | bash -s 3.11

set -e
PYTHON_VERSION=${1:-3.11}

echo "🔧 DevForge: Instalando IA/ML Stack com Python ${PYTHON_VERSION}..."

# Instalar dependências do sistema
echo "📦 Instalando dependências do sistema..."
sudo apt update
sudo apt install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev \
    build-essential libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncurses5-dev libgdbm-dev zlib1g-dev uuid-dev tk-dev

# Instalar pipx e ferramentas globais
python3 -m pip install --upgrade pip
python3 -m pip install pipx
pipx ensurepath

# Instalar CUDA Toolkit (se NVIDIA GPU detectada)
if command -v nvidia-smi &> /dev/null; then
    echo "🎮 NVIDIA GPU detectada. Instalando CUDA Toolkit..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt update
    sudo apt install -y cuda-toolkit-12 cudnn-cuda-12
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
fi

# Criar ambiente virtual
echo "📦 Criando ambiente virtual para IA/ML..."
python${PYTHON_VERSION} -m venv ~/ia-env
source ~/ia-env/bin/activate

# Instalar bibliotecas essenciais
echo "📦 Instalando bibliotecas Python para IA/ML..."

# Core ML
pip install numpy pandas scipy matplotlib seaborn scikit-learn jupyterlab notebook ipykernel ipywidgets

# Deep Learning
pip install tensorflow tensorflow-datasets
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# NLP/LLMs
pip install transformers datasets accelerate tokenizers evaluate
pip install langchain langchain-community chromadb openai tiktoken
pip install ollama

# MLOps
pip install mlflow dagshub optuna hyperopt

# Computer Vision
pip install opencv-python pillow albumentations

# LLM Local (Ollama)
echo "📦 Instalando Ollama para LLMs locais..."
curl -fsSL https://ollama.com/install.sh | sh

# Configurar kernel do Jupyter
python -m ipykernel install --user --name=ia-env --display-name="Python (IA/ML)"

echo "✅ IA/ML Stack instalada com sucesso!"
echo "💡 Ative o ambiente: source ~/ia-env/bin/activate"
echo "💡 Inicie o Jupyter: jupyter lab"
echo "💡 Inicie o MLflow: mlflow ui"
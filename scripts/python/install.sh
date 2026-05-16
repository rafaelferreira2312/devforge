#!/bin/bash
# DevForge - Python Installer for Linux/macOS
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/python/install.sh | bash -s 3.12

set -e
PYTHON_VERSION=${1:-3.12}
BACKUP_FILE="$HOME/pip-packages-backup-$(date +%Y%m%d_%H%M%S).txt"

echo "🔧 DevForge: Instalando Python ${PYTHON_VERSION}..."

# Backup dos pacotes pip atuais
if command -v pip3 &> /dev/null; then
    echo "📦 Fazendo backup dos pacotes pip..."
    pip3 freeze > "$BACKUP_FILE"
    echo "✅ Backup salvo em: $BACKUP_FILE"
fi

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        echo "❌ SO não suportado diretamente. Use WSL ou Docker."
        exit 1
    fi
}

install_linux() {
    echo "🐧 Detectado Linux"
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev
    sudo apt install -y python3-pip python3-venv
}

install_macos() {
    echo "🍎 Detectado macOS"
    if ! command -v brew &> /dev/null; then
        echo "📦 Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install python@${PYTHON_VERSION}
}

detect_os
case $OS in
    macos) install_macos ;;
    *) install_linux ;;
esac

# Instalar pipx e ferramentas globais úteis
python3 -m pip install --upgrade pip
python3 -m pip install --user pipx
pipx ensurepath
pipx install poetry
pipx install black
pipx install flake8

echo "✅ Python ${PYTHON_VERSION} instalado com sucesso!"
python3 --version
pip3 --version
echo "💡 Ferramentas instaladas: poetry, black, flake8"
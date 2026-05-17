#!/bin/bash
# DevForge - .NET SDK Installer for Linux/macOS
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/csharp/install-dotnet.sh | bash -s 8.0

set -e
DOTNET_VERSION=${1:-8.0}

echo "🔧 DevForge: Instalando .NET SDK ${DOTNET_VERSION}..."

# Adicionar repositório Microsoft (Ubuntu/Debian)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Detectado Linux"
    wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y dotnet-sdk-${DOTNET_VERSION}
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Detectado macOS"
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install --cask dotnet-sdk
fi

# Verificar instalação
dotnet --info

echo "✅ .NET SDK ${DOTNET_VERSION} instalado com sucesso!"
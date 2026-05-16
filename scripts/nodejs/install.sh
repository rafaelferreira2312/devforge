#!/bin/bash
# DevForge - Node.js Installer for Linux/macOS
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/nodejs/install.sh | bash -s 20

set -e
NODE_VERSION=${1:-20}
BACKUP_FILE="$HOME/npm-global-backup-$(date +%Y%m%d_%H%M%S).txt"

echo "🔧 DevForge: Instalando Node.js ${NODE_VERSION}..."

# Backup dos pacotes globais atuais
if command -v npm &> /dev/null; then
    echo "📦 Fazendo backup dos pacotes npm globais..."
    npm list -g --depth=0 > "$BACKUP_FILE"
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
    # Usar NodeSource repositório oficial
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
    sudo apt install -y nodejs
}

install_macos() {
    echo "🍎 Detectado macOS"
    if ! command -v brew &> /dev/null; then
        echo "📦 Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install node@${NODE_VERSION}
    brew link --overwrite node@${NODE_VERSION}
}

detect_os
case $OS in
    macos) install_macos ;;
    *) install_linux ;;
esac

# Instalar npm global útil
npm install -g npm@latest
npm install -g yarn pm2 nodemon

echo "✅ Node.js ${NODE_VERSION} instalado com sucesso!"
node -v
npm -v
echo "💡 Pacotes globais instalados: yarn, pm2, nodemon"
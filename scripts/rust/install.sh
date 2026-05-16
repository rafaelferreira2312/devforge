#!/bin/bash
# DevForge - Rust Installer for Linux/macOS
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/rust/install.sh | bash -s stable

set -e
RUST_TOOLCHAIN=${1:-stable}
BACKUP_FILE="$HOME/rust-backup-$(date +%Y%m%d_%H%M%S).txt"

echo "🔧 DevForge: Instalando Rust (toolchain: ${RUST_TOOLCHAIN})..."

# Backup das crates instaladas
if command -v cargo &> /dev/null; then
    echo "📦 Fazendo backup das crates instaladas globalmente..."
    cargo install --list > "$BACKUP_FILE" 2>/dev/null || true
    echo "✅ Backup salvo em: $BACKUP_FILE"
fi

# Instalar dependências de sistema necessárias
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "🐧 Detectado Linux - Instalando dependências..."
        sudo apt update
        sudo apt install -y build-essential pkg-config libssl-dev curl
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🍎 Detectado macOS - Instalando dependências..."
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install openssl
    else
        echo "❌ SO não suportado diretamente. Use WSL ou Docker."
        exit 1
    fi
}

detect_os

# Instalar rustup (oficial)
echo "📦 Instalando rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_TOOLCHAIN}

# Configurar PATH
source "$HOME/.cargo/env"
echo 'source "$HOME/.cargo/env"' >> ~/.bashrc
echo 'source "$HOME/.cargo/env"' >> ~/.zshrc 2>/dev/null || true

# Verificar instalação
rustc --version
cargo --version
rustup --version

# Instalar componentes úteis
rustup component add clippy
rustup component add rustfmt
rustup component add rust-docs

echo "✅ Rust (${RUST_TOOLCHAIN}) instalado com sucesso!"
echo "💡 Componentes: clippy, rustfmt, rust-docs"
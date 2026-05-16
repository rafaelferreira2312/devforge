#!/bin/bash
# DevForge - Go Installer for Linux/macOS
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/go/install.sh | bash -s 1.23

set -e
GO_VERSION=${1:-1.23}
BACKUP_FILE="$HOME/go-env-backup-$(date +%Y%m%d_%H%M%S).txt"

echo "🔧 DevForge: Instalando Go ${GO_VERSION}..."

# Backup do GOPATH atual
if [ -n "$GOPATH" ]; then
    echo "📦 Fazendo backup do GOPATH atual..."
    echo "GOPATH=$GOPATH" > "$BACKUP_FILE"
    echo "GOROOT=$GOROOT" >> "$BACKUP_FILE"
    echo "✅ Backup salvo em: $BACKUP_FILE"
fi

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        ARCH="amd64"
        if [[ "$(uname -m)" == "aarch64" ]]; then
            ARCH="arm64"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="darwin"
        ARCH="amd64"
        if [[ "$(uname -m)" == "arm64" ]]; then
            ARCH="arm64"
        fi
    else
        echo "❌ SO não suportado diretamente. Use WSL ou Docker."
        exit 1
    fi
}

install_linux() {
    echo "🐧 Detectado Linux ($ARCH)"
    GO_PACKAGE="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
    wget -q "https://go.dev/dl/${GO_PACKAGE}"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "${GO_PACKAGE}"
    rm "${GO_PACKAGE}"
    
    # Configurar PATH e GOPATH
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
    echo "export GOPATH=\$HOME/go" >> ~/.bashrc
    echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
}

install_macos() {
    echo "🍎 Detectado macOS ($ARCH)"
    if ! command -v brew &> /dev/null; then
        echo "📦 Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install go@${GO_VERSION}
    brew link --overwrite go@${GO_VERSION}
    
    # Configurar GOPATH
    echo "export GOPATH=\$HOME/go" >> ~/.zshrc
    echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.zshrc
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
}

detect_os
case $OS in
    darwin) install_macos ;;
    *) install_linux ;;
esac

# Criar estrutura GOPATH
mkdir -p $HOME/go/{bin,src,pkg}

# Instalar ferramentas populares
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/cosmtrek/air@latest

echo "✅ Go ${GO_VERSION} instalado com sucesso!"
go version
go env GOPATH
echo "💡 Ferramentas instaladas: gopls, dlv, golangci-lint, air"
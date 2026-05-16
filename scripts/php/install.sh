#!/bin/bash
# DevForge - PHP Installer for Linux/macOS
# Usage: curl -fsSL https://devforge.sh/install/php.sh | bash -s 8.3

set -e
PHP_VERSION=${1:-8.3}
BACKUP_SUFFIX=".devforge.bak.$(date +%Y%m%d_%H%M%S)"

echo "🔧 DevForge: Instalando PHP ${PHP_VERSION}..."

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        echo "❌ SO não suportado diretamente. Use WSL ou Docker."
        exit 1
    fi
}

backup_php_ini() {
    local ini_path="$1"
    if [ -f "$ini_path" ]; then
        cp "$ini_path" "${ini_path}${BACKUP_SUFFIX}"
        echo "✅ Backup criado: ${ini_path}${BACKUP_SUFFIX}"
    fi
}

install_linux() {
    echo "🐧 Detectado Linux ($OS)"
    case $OS in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y software-properties-common
            sudo add-apt-repository -y ppa:ondrej/php
            sudo apt update
            sudo apt install -y php${PHP_VERSION} php${PHP_VERSION}-cli php${PHP_VERSION}-fpm \
                php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-xml \
                php${PHP_VERSION}-zip php${PHP_VERSION}-mbstring php${PHP_VERSION}-gd
            backup_php_ini "/etc/php/${PHP_VERSION}/cli/php.ini"
            ;;
        rhel|centos|fedora)
            sudo dnf install -y epel-release
            sudo dnf module reset php -y
            sudo dnf module install php:${PHP_VERSION} -y
            backup_php_ini "/etc/php.ini"
            ;;
        *)
            echo "⚠️ Distribuição não testada. Tentando instalar via pacote padrão."
            sudo apt install -y php${PHP_VERSION} || sudo dnf install -y php${PHP_VERSION}
            ;;
    esac
}

install_macos() {
    echo "🍎 Detectado macOS"
    if ! command -v brew &> /dev/null; then
        echo "📦 Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install php@${PHP_VERSION}
    brew link --force --overwrite php@${PHP_VERSION}
    backup_php_ini "$(brew --prefix)/etc/php/${PHP_VERSION}/php.ini"
}

detect_os
case $OS in
    macos) install_macos ;;
    *) install_linux ;;
esac

echo "✅ PHP ${PHP_VERSION} instalado com sucesso!"
php -v
echo "💡 Execute 'composer self-update' para atualizar o Composer (se instalado)"

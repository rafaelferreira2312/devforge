#!/bin/bash
# DevForge - Ruby on Rails Installer for Linux/macOS
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/rails/install.sh | bash -s 3.2

set -e
RUBY_VERSION=${1:-3.2}
BACKUP_FILE="$HOME/gem-backup-$(date +%Y%m%d_%H%M%S).txt"

echo "🔧 DevForge: Instalando Ruby ${RUBY_VERSION} e Rails..."

# Backup das gems instaladas
if command -v gem &> /dev/null; then
    echo "📦 Fazendo backup das gems instaladas globalmente..."
    gem list > "$BACKUP_FILE"
    echo "✅ Backup salvo em: $BACKUP_FILE"
fi

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "🐧 Detectado Linux - Instalando dependências..."
        sudo apt update
        sudo apt install -y git curl autoconf bison build-essential libssl-dev libyaml-dev \
            libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
            libsqlite3-dev libpq-dev postgresql postgresql-contrib mysql-server \
            nodejs yarnpkg
        sudo ln -s /usr/bin/yarnpkg /usr/bin/yarn 2>/dev/null || true
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🍎 Detectado macOS - Instalando dependências..."
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew update
        brew install ruby-build rbenv postgresql mysql node yarn
        echo 'eval "$(rbenv init -)"' >> ~/.zshrc
        eval "$(rbenv init -)"
    else
        echo "❌ SO não suportado diretamente. Use WSL ou Docker."
        exit 1
    fi
}

detect_os

# Instalar RVM (Linux) ou rbenv (macOS)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "📦 Instalando RVM..."
    gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    echo 'source ~/.rvm/scripts/rvm' >> ~/.bashrc
    
    echo "📦 Instalando Ruby ${RUBY_VERSION} via RVM..."
    rvm install ${RUBY_VERSION}
    rvm use ${RUBY_VERSION} --default
fi

# Instalar Rails e gems essenciais
echo "📦 Instalando Rails..."
gem install rails bundler pg mysql2 sqlite3

# Instalar Node.js e Yarn para assets
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
fi

echo "✅ Ruby on Rails instalado com sucesso!"
ruby -v
rails -v
echo "💡 PostgreSQL e MySQL instalados. Configure suas credenciais no config/database.yml"
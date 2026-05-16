#!/bin/bash
# DevForge - Docker Installer for Linux
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/docker/install-docker.sh | bash

set -e

echo "🔧 DevForge: Instalando Docker no Linux..."

# Remover versões antigas
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Instalar dependências
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Adicionar repositório oficial Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose standalone
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Instalar Docker Scout
docker buildx install

echo "✅ Docker instalado com sucesso!"
echo "💡 Execute 'newgrp docker' ou reinicie o terminal para usar Docker sem sudo"
docker --version
docker-compose --version
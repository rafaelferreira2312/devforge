#!/bin/bash
# DevForge - PHP Environment Installer
echo "🟢 Atualizando sistema..."
sudo apt update && sudo apt upgrade -y
echo "🐘 Instalando PHP 8.3..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt install php8.3 php8.3-cli php8.3-fpm php8.3-mysql php8.3-curl php8.3-xml -y
echo "✅ PHP instalado com sucesso"

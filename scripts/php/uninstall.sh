#!/bin/bash
# DevForge - PHP Uninstaller

PHP_VERSION=${1:-8.3}
echo "⚠️ Removendo PHP $PHP_VERSION..."

read -p "Deseja restaurar o último backup do php.ini? (s/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    find /etc/php -name "*.devforge.bak.*" -exec sh -c 'cp "$1" "${1%%.devforge.bak.*}"' _ {} \;
    echo "✅ Backups restaurados."
fi

sudo apt purge -y php${PHP_VERSION}* || sudo dnf remove -y php${PHP_VERSION}
sudo apt autoremove -y
echo "🗑️ PHP $PHP_VERSION removido."

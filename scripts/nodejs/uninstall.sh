#!/bin/bash
# DevForge - Node.js Uninstaller

NODE_VERSION=${1:-20}
echo "⚠️ Removendo Node.js $NODE_VERSION..."

read -p "Deseja preservar o backup dos pacotes globais? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    rm -f ~/npm-global-backup-*.txt
    echo "🗑️ Backups removidos."
fi

sudo apt remove -y nodejs || sudo dnf remove -y nodejs || brew uninstall node@${NODE_VERSION}
sudo apt autoremove -y
echo "🗑️ Node.js $NODE_VERSION removido."
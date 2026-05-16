#!/bin/bash
# DevForge - Go Uninstaller

GO_VERSION=${1:-1.23}
echo "⚠️ Removendo Go $GO_VERSION..."

read -p "Deseja preservar o backup das variáveis de ambiente? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    rm -f ~/go-env-backup-*.txt
    echo "🗑️ Backups removidos."
fi

sudo rm -rf /usr/local/go
sudo apt remove -y golang-go || brew uninstall go@${GO_VERSION}
rm -rf ~/go

echo "🗑️ Go $GO_VERSION removido."
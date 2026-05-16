#!/bin/bash
# DevForge - Python Uninstaller

PYTHON_VERSION=${1:-3.12}
echo "⚠️ Removendo Python $PYTHON_VERSION..."

read -p "Deseja preservar o backup dos pacotes pip? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    rm -f ~/pip-packages-backup-*.txt
    echo "🗑️ Backups removidos."
fi

sudo apt remove -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv || brew uninstall python@${PYTHON_VERSION}
sudo apt autoremove -y
echo "🗑️ Python $PYTHON_VERSION removido."
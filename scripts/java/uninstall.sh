#!/bin/bash
# DevForge - Java JDK Uninstaller

JDK_VERSION=${1:-21}
echo "⚠️ Removendo JDK $JDK_VERSION..."

read -p "Deseja preservar o backup das variáveis de ambiente? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    rm -f ~/java-env-backup-*.txt
    echo "🗑️ Backups removidos."
fi

sudo apt remove -y openjdk-${JDK_VERSION}-jdk openjdk-${JDK_VERSION}-jre maven gradle || brew uninstall openjdk@${JDK_VERSION} maven gradle
sudo apt autoremove -y
echo "🗑️ JDK $JDK_VERSION removido."
#!/bin/bash
# DevForge - Rust Uninstaller

echo "⚠️ Removendo Rust..."

read -p "Deseja preservar o backup das crates? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    rm -f ~/rust-backup-*.txt
    echo "🗑️ Backups removidos."
fi

# Remover rustup e tudo relacionado
rustup self uninstall -y

# Limpar diretórios residuais
rm -rf ~/.cargo
rm -rf ~/.rustup

echo "🗑️ Rust removido completamente."
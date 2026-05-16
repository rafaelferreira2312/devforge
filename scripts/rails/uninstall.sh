#!/bin/bash
# DevForge - Ruby on Rails Uninstaller

echo "⚠️ Removendo Ruby on Rails..."

read -p "Deseja preservar o backup das gems? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    rm -f ~/gem-backup-*.txt
    echo "🗑️ Backups removidos."
fi

# Remover RVM
if command -v rvm &> /dev/null; then
    rvm implode --force
fi

# Remover rbenv (macOS)
if [ -d ~/.rbenv ]; then
    rm -rf ~/.rbenv
    sed -i '/rbenv/d' ~/.zshrc 2>/dev/null || true
fi

# Remover diretórios Ruby
rm -rf ~/.gem
rm -rf ~/.rvm

echo "🗑️ Ruby on Rails removido completamente."
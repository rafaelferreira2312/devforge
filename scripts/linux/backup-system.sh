#!/bin/bash
# DevForge - System Backup Script

BACKUP_DIR="$HOME/backup-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

echo "📦 DevForge: Realizando backup..."

# Backup de configurações
cp -r ~/.bashrc ~/.bash_aliases ~/.gitconfig "$BACKUP_DIR/" 2>/dev/null

# Backup de scripts
cp -r ~/scripts "$BACKUP_DIR/" 2>/dev/null

# Backup de projetos
tar -czf "$BACKUP_DIR/projetos.tar.gz" ~/projects 2>/dev/null

echo "✅ Backup salvo em: $BACKUP_DIR"
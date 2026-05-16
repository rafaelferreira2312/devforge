#!/bin/bash
BACKUP_DIR="$HOME/devforge-backups/python-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

pip3 freeze > "$BACKUP_DIR/pip-packages.txt"
pip3 list --outdated > "$BACKUP_DIR/outdated-packages.txt"

tar -czf "$BACKUP_DIR/python-backup.tar.gz" -C "$BACKUP_DIR" .
echo "✅ Backup salvo em $BACKUP_DIR/python-backup.tar.gz"
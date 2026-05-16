#!/bin/bash
BACKUP_DIR="$HOME/devforge-backups/nodejs-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

npm list -g --depth=0 > "$BACKUP_DIR/npm-global.txt"
npm config list > "$BACKUP_DIR/npm-config.txt"

tar -czf "$BACKUP_DIR/nodejs-backup.tar.gz" -C "$BACKUP_DIR" .
echo "✅ Backup salvo em $BACKUP_DIR/nodejs-backup.tar.gz"
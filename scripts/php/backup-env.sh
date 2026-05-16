#!/bin/bash
BACKUP_DIR="$HOME/devforge-backups/php-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
sudo cp -r /etc/php "$BACKUP_DIR/" 2>/dev/null || echo "Nenhum /etc/php encontrado"
tar -czf "$BACKUP_DIR/php-backup.tar.gz" -C "$BACKUP_DIR" .
echo "✅ Backup salvo em $BACKUP_DIR/php-backup.tar.gz"

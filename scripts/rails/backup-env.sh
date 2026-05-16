#!/bin/bash
BACKUP_DIR="$HOME/devforge-backups/rails-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

ruby -v > "$BACKUP_DIR/ruby-version.txt"
rails -v > "$BACKUP_DIR/rails-version.txt"
gem list > "$BACKUP_DIR/gems-list.txt"
bundle list --all > "$BACKUP_DIR/bundle-list.txt" 2>/dev/null || true

tar -czf "$BACKUP_DIR/rails-backup.tar.gz" -C "$BACKUP_DIR" .
echo "✅ Backup salvo em $BACKUP_DIR/rails-backup.tar.gz"
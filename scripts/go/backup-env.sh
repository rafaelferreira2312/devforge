#!/bin/bash
BACKUP_DIR="$HOME/devforge-backups/go-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "GOPATH=$GOPATH" > "$BACKUP_DIR/go-env.txt"
echo "GOROOT=$GOROOT" >> "$BACKUP_DIR/go-env.txt"
go version > "$BACKUP_DIR/go-version.txt" 2>&1
go env > "$BACKUP_DIR/go-env-full.txt" 2>&1

# Backup dos módulos locais
if [ -d "$GOPATH/src" ]; then
    tar -czf "$BACKUP_DIR/go-src-backup.tar.gz" -C "$GOPATH/src" . 2>/dev/null || true
fi

tar -czf "$BACKUP_DIR/go-backup.tar.gz" -C "$BACKUP_DIR" .
echo "✅ Backup salvo em $BACKUP_DIR/go-backup.tar.gz"
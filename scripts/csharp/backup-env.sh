#!/bin/bash
BACKUP_DIR="$HOME/devforge-backups/dotnet-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

dotnet --info > "$BACKUP_DIR/dotnet-info.txt"
dotnet --list-sdks > "$BACKUP_DIR/dotnet-sdks.txt"
dotnet --list-runtimes > "$BACKUP_DIR/dotnet-runtimes.txt"

tar -czf "$BACKUP_DIR/dotnet-backup.tar.gz" -C "$BACKUP_DIR" .
echo "✅ Backup salvo em $BACKUP_DIR/dotnet-backup.tar.gz"
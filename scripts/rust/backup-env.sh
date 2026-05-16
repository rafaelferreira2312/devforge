#!/bin/bash
BACKUP_DIR="$HOME/devforge-backups/rust-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

rustc --version > "$BACKUP_DIR/rustc-version.txt"
cargo --version > "$BACKUP_DIR/cargo-version.txt"
rustup show > "$BACKUP_DIR/rustup-show.txt"
cargo install --list > "$BACKUP_DIR/crates-list.txt"
cargo tree --depth 1 > "$BACKUP_DIR/dependencies.txt" 2>/dev/null || true

tar -czf "$BACKUP_DIR/rust-backup.tar.gz" -C "$BACKUP_DIR" .
echo "✅ Backup salvo em $BACKUP_DIR/rust-backup.tar.gz"
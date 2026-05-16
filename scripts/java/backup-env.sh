#!/bin/bash
BACKUP_DIR="$HOME/devforge-backups/java-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "JAVA_HOME=$JAVA_HOME" > "$BACKUP_DIR/java-env.txt"
echo "PATH=$PATH" >> "$BACKUP_DIR/java-env.txt"
java -version 2>&1 > "$BACKUP_DIR/java-version.txt"
mvn --version > "$BACKUP_DIR/maven-version.txt" 2>&1
gradle --version > "$BACKUP_DIR/gradle-version.txt" 2>&1

tar -czf "$BACKUP_DIR/java-backup.tar.gz" -C "$BACKUP_DIR" .
echo "✅ Backup salvo em $BACKUP_DIR/java-backup.tar.gz"
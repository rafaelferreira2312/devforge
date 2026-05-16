#!/bin/bash
# DevForge - Docker Cleanup Script

echo "🧹 Limpando Docker..."

# Parar todos containers
docker stop $(docker ps -aq) 2>/dev/null || true

# Remover todos containers
docker rm $(docker ps -aq) 2>/dev/null || true

# Remover todas imagens não usadas
docker rmi $(docker images -q) 2>/dev/null || true

# Sistema prune
docker system prune -a -f
docker volume prune -f
docker network prune -f
docker builder prune -f

echo "✅ Limpeza concluída!"
docker system df
#!/bin/bash
# DevForge - System Optimization Script

echo "🔧 DevForge: Otimizando o sistema..."

# Limpar logs antigos
sudo journalctl --vacuum-time=3d
sudo find /var/log -type f -name "*.log" -mtime +30 -delete

# Limpar cache do apt
sudo apt clean
sudo apt autoremove -y

# Ajustar swappiness
sudo sysctl vm.swappiness=10
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

# Aumentar limite de arquivos
echo "* soft nofile 65535" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65535" | sudo tee -a /etc/security/limits.conf

echo "✅ Sistema otimizado!"
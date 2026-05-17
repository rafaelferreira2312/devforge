#!/bin/bash
# DevForge - Network Scanner

TARGET=${1:-192.168.1.0/24}

echo "🔍 Escaneando rede: $TARGET"

# Descoberta de hosts
echo "📡 Hosts ativos:"
nmap -sn $TARGET | grep "Nmap scan" | cut -d' ' -f5

# Portas abertas
echo ""
echo "🔓 Portas abertas:"
nmap -sS -sV -p- --min-rate=1000 $TARGET

echo "✅ Scan concluído!"
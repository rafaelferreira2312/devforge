#!/bin/bash
# DevForge - Security Audit Script

echo "🔒 DevForge: Auditoria de segurança..."

# Verificar updates pendentes
echo "📦 Updates pendentes:"
apt list --upgradable 2>/dev/null | grep -v "Listing" | head -5

# Verificar usuários com sudo
echo ""
echo "👥 Usuários com sudo:"
grep -Po '^sudo.+:\K.*$' /etc/group

# Verificar portas abertas
echo ""
echo "🌐 Portas abertas:"
ss -tuln | grep LISTEN

# Verificar falhas de login
echo ""
echo "🔐 Falhas de login recentes:"
sudo lastb | head -5

echo "✅ Auditoria concluída!"
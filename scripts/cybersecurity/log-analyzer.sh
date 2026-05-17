#!/bin/bash
# DevForge - Log Analyzer

LOG_FILE=${1:-/var/log/auth.log}

echo "📊 Analisando log: $LOG_FILE"

# Tentativas de login falhas
echo "🔐 Tentativas de login falhas:"
grep "Failed password" $LOG_FILE | wc -l

# Tentativas de login bem-sucedidas
echo ""
echo "✅ Tentativas de login bem-sucedidas:"
grep "Accepted password" $LOG_FILE | wc -l

# IPs suspeitos
echo ""
echo "⚠️ IPs com múltiplas falhas (>5):"
grep "Failed password" $LOG_FILE | awk '{print $(NF-3)}' | sort | uniq -c | awk '$1>5 {print $2}'

echo "✅ Análise concluída!"
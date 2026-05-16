#!/bin/bash
# DevForge - Linux Diagnostic Script
# Usage: curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/linux/diagnostic.sh | bash

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           DevForge - Linux Hardware Diagnostic Tool v1.0            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ==================== COLETA DE INFORMAÇÕES ====================
echo -e "${YELLOW}🔍 Coletando informações do sistema...${NC}"

# Sistema Operacional
OS_NAME=$(lsb_release -ds 2>/dev/null || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2)
KERNEL=$(uname -r)
ARCH=$(uname -m)

# CPU
CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
CPU_CORES=$(nproc)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)

# Memória RAM
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/^Mem:/ {print $3}')
RAM_FREE=$(free -h | awk '/^Mem:/ {print $4}')
RAM_PERCENT=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100}')

# Disco
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_FREE=$(df -h / | awk 'NR==2 {print $4}')
DISK_PERCENT=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

# Rede
IP_ADDR=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | head -1)
HOSTNAME=$(hostname)

# GPU
if command -v nvidia-smi &> /dev/null; then
    GPU_MODEL=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
    GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader | head -1)
    GPU_STATUS="NVIDIA (CUDA disponível)"
else
    GPU_MODEL=$(lspci | grep -E "VGA|3D" | grep -v "Hypervisor" | cut -d':' -f3 | xargs)
    GPU_STATUS="Sem GPU dedicada"
fi

# ==================== EXIBIÇÃO DOS RESULTADOS ====================
echo ""
echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│                       SISTEMA OPERACIONAL                       │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo -e "   📀 SO: ${BLUE}$OS_NAME${NC}"
echo -e "   🐧 Kernel: ${BLUE}$KERNEL${NC}"
echo -e "   🏗️ Arquitetura: ${BLUE}$ARCH${NC}"
echo -e "   💻 Hostname: ${BLUE}$HOSTNAME${NC}"
echo ""

echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│                              CPU                                 │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo -e "   🖥️ Modelo: ${BLUE}$CPU_MODEL${NC}"
echo -e "   ⚡ Núcleos: ${BLUE}$CPU_CORES${NC}"
echo -e "   📊 Uso atual: ${BLUE}${CPU_USAGE}%${NC}"

# Avaliação CPU
if [ $CPU_CORES -ge 8 ]; then
    echo -e "   ✅ ${GREEN}Avaliação: Excelente para qualquer stack${NC}"
elif [ $CPU_CORES -ge 4 ]; then
    echo -e "   ✅ ${GREEN}Avaliação: Bom para maioria das stacks${NC}"
elif [ $CPU_CORES -ge 2 ]; then
    echo -e "   ⚠️ ${YELLOW}Avaliação: OK para tarefas básicas${NC}"
else
    echo -e "   ❌ ${RED}Avaliação: Limitado, recomendado upgrade${NC}"
fi
echo ""

echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│                          MEMÓRIA RAM                            │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo -e "   💾 Total: ${BLUE}$RAM_TOTAL${NC}"
echo -e "   📊 Em uso: ${BLUE}$RAM_USED (${RAM_PERCENT}%)${NC}"
echo -e "   📊 Livre: ${BLUE}$RAM_FREE${NC}"

# Avaliação RAM
RAM_GB=$(echo $RAM_TOTAL | sed 's/Gi//' | sed 's/GB//')
if [ $(echo "$RAM_GB >= 32" | bc) -eq 1 ]; then
    echo -e "   ✅ ${GREEN}Avaliação: Excelente para IA/ML, Containers, Big Data${NC}"
elif [ $(echo "$RAM_GB >= 16" | bc) -eq 1 ]; then
    echo -e "   ✅ ${GREEN}Avaliação: Ótimo para desenvolvimento geral${NC}"
elif [ $(echo "$RAM_GB >= 8" | bc) -eq 1 ]; then
    echo -e "   ⚠️ ${YELLOW}Avaliação: Bom, mas limitado para containers/IA${NC}"
elif [ $(echo "$RAM_GB >= 4" | bc) -eq 1 ]; then
    echo -e "   ⚠️ ${YELLOW}Avaliação: Mínimo para desenvolvimento web${NC}"
else
    echo -e "   ❌ ${RED}Avaliação: Insuficiente, considere upgrade${NC}"
fi
echo ""

echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│                          ARMAZENAMENTO                          │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo -e "   💽 Total: ${BLUE}$DISK_TOTAL${NC}"
echo -e "   📊 Usado: ${BLUE}$DISK_USED (${DISK_PERCENT}%)${NC}"
echo -e "   📊 Livre: ${BLUE}$DISK_FREE${NC}"

# Avaliação Disco
DISK_GB=$(echo $DISK_TOTAL | sed 's/G//' | sed 's/T/*1024/' | bc 2>/dev/null || echo 0)
if [ $(echo "$DISK_GB >= 1000" | bc) -eq 1 ]; then
    echo -e "   ✅ ${GREEN}Avaliação: Excelente para projetos grandes${NC}"
elif [ $(echo "$DISK_GB >= 256" | bc) -eq 1 ]; then
    echo -e "   ✅ ${GREEN}Avaliação: Suficiente para desenvolvimento${NC}"
elif [ $(echo "$DISK_GB >= 100" | bc) -eq 1 ]; then
    echo -e "   ⚠️ ${YELLOW}Avaliação: OK, mas gerencie espaço${NC}"
else
    echo -e "   ❌ ${RED}Avaliação: Espaço limitado${NC}"
fi

if [ $DISK_PERCENT -gt 85 ]; then
    echo -e "   ⚠️ ${YELLOW}Atenção: Disco quase cheio! Limpeza recomendada.${NC}"
fi
echo ""

echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│                              GPU                                 │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo -e "   🎮 GPU: ${BLUE}$GPU_MODEL${NC}"
echo -e "   📊 Status: ${BLUE}$GPU_STATUS${NC}"
if echo "$GPU_STATUS" | grep -q "NVIDIA"; then
    echo -e "   ✅ ${GREEN}Avaliação: Ideal para Deep Learning e IA${NC}"
elif echo "$GPU_STATUS" | grep -q "AMD"; then
    echo -e "   ⚠️ ${YELLOW}Avaliação: OK para jogos, limitado para ML${NC}"
else
    echo -e "   ⚠️ ${YELLOW}Avaliação: Sem GPU dedicada - CPU-only mode${NC}"
fi
echo ""

echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│                             REDE                                 │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo -e "   🌐 IP Local: ${BLUE}$IP_ADDR${NC}"
echo ""

# ==================== SOFTWARE INSTALADO ====================
echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│                    SOFTWARE INSTALADO                           │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"

check_software() {
    if command -v $1 &> /dev/null; then
        VERSION=$($1 --version 2>/dev/null | head -1 | cut -d' ' -f2- | head -c 50)
        echo -e "   ✅ ${GREEN}$1${NC}: $VERSION"
        return 0
    else
        echo -e "   ❌ ${RED}$1${NC}: Não instalado"
        return 1
    fi
}

check_software python3
check_software node
check_software npm
check_software docker
check_software docker-compose
check_software git
check_software curl
check_software wget
check_software gcc
check_software java
check_software go
check_software rustc
check_software php
echo ""

# ==================== RECOMENDAÇÃO DE STACK ====================
echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}│                 🚀 RECOMENDAÇÃO DE STACK 🚀                       │${NC}"
echo -e "${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"

SCORE=0
MAX_SCORE=10

# CPU Score
if [ $CPU_CORES -ge 8 ]; then
    SCORE=$((SCORE + 3))
elif [ $CPU_CORES -ge 4 ]; then
    SCORE=$((SCORE + 2))
elif [ $CPU_CORES -ge 2 ]; then
    SCORE=$((SCORE + 1))
fi

# RAM Score
if [ $(echo "$RAM_GB >= 32" | bc) -eq 1 ]; then
    SCORE=$((SCORE + 4))
elif [ $(echo "$RAM_GB >= 16" | bc) -eq 1 ]; then
    SCORE=$((SCORE + 3))
elif [ $(echo "$RAM_GB >= 8" | bc) -eq 1 ]; then
    SCORE=$((SCORE + 2))
elif [ $(echo "$RAM_GB >= 4" | bc) -eq 1 ]; then
    SCORE=$((SCORE + 1))
fi

# Disk Score
if [ $(echo "$DISK_GB >= 500" | bc) -eq 1 ]; then
    SCORE=$((SCORE + 3))
elif [ $(echo "$DISK_GB >= 200" | bc) -eq 1 ]; then
    SCORE=$((SCORE + 2))
elif [ $(echo "$DISK_GB >= 100" | bc) -eq 1 ]; then
    SCORE=$((SCORE + 1))
fi

echo -e "   📊 Pontuação geral: ${BLUE}$SCORE / $MAX_SCORE${NC}"
echo ""

if [ $SCORE -ge 8 ]; then
    echo -e "   🎯 ${GREEN}SUA MÁQUINA É POWER USER!${NC}"
    echo -e "   ✅ Recomendado para:"
    echo -e "      • ${BLUE}DevOps${NC} (Kubernetes, Docker, Terraform)"
    echo -e "      • ${BLUE}IA/ML${NC} (TensorFlow, PyTorch com GPU)"
    echo -e "      • ${BLUE}Big Data${NC} (Spark, Hadoop)"
    echo -e "      • ${BLUE}Múltiplos containers${NC} simultaneamente"
elif [ $SCORE -ge 6 ]; then
    echo -e "   🎯 ${GREEN}MÁQUINA DE DESENVOLVEDOR PROFISSIONAL${NC}"
    echo -e "   ✅ Recomendado para:"
    echo -e "      • ${BLUE}Backend${NC} (Node.js, Python, Java, Go, Rust)"
    echo -e "      • ${BLUE}Frontend${NC} (React, Vue, Angular)"
    echo -e "      • ${BLUE}Mobile${NC} (React Native, Flutter)"
    echo -e "      • ${BLUE}Docker${NC} (até 5 containers simultâneos)"
elif [ $SCORE -ge 4 ]; then
    echo -e "   🎯 ${YELLOW}MÁQUINA DE ESTUDOS / INICIANTE${NC}"
    echo -e "   ✅ Recomendado para:"
    echo -e "      • ${BLUE}Web Development${NC} (PHP, Node.js, Python)"
    echo -e "      • ${BLUE}Scripts e automação${NC}"
    echo -e "      • ${BLUE}Estudos${NC} de programação"
    echo -e "      • ⚠️ Evite containers pesados"
else
    echo -e "   🎯 ${RED}MÁQUINA BÁSICA / LEGACY${NC}"
    echo -e "   ✅ Recomendado para:"
    echo -e "      • ${BLUE}Terminal / CLI tools${NC}"
    echo -e "      • ${BLUE}Servidor leve${NC} (Nginx, Apache)"
    echo -e "      • ${BLUE}Automação simples${NC}"
    echo -e "      • ⚠️ Considere upgrade para melhor experiência"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Diagnóstico concluído!${NC}"
echo -e "${YELLOW}💡 Dica: Execute 'optimize-system.sh' para melhorar performance${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
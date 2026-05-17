#!/bin/bash
# DevForge - Security Tools Installer for Kali/Ubuntu/Debian

set -e

echo "🔧 DevForge: Instalando Security Tools..."

# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Ferramentas de rede e reconhecimento
echo "📦 Instalando Nmap, Masscan, Netcat..."
sudo apt install -y nmap masscan netcat-openbsd

# Web Application Testing
echo "📦 Instalando Burp Suite, SQLmap, Nikto, Gobuster, Dirb, WPScan, WhatWeb..."
sudo apt install -y burpsuite sqlmap nikto gobuster dirb wpscan whatweb

# Exploitation
echo "📦 Instalando Metasploit, SearchSploit, BeEF..."
sudo apt install -y metasploit-framework exploitdb beef-xss

# Password Cracking
echo "📦 Instalando John, Hydra, Hashcat..."
sudo apt install -y john hydra hashcat

# Packet Analysis
echo "📦 Instalando Wireshark, Tcpdump..."
sudo apt install -y wireshark tcpdump

# Post-Exploitation
echo "📦 Instalando Impacket, Empire..."
sudo apt install -y python3-impacket
git clone https://github.com/BC-SECURITY/Empire.git ~/Empire

# Ferramentas adicionais
echo "📦 Instalando ferramentas adicionais..."
sudo apt install -y steghide binwalk foremost testdisk
sudo apt install -y aircrack-ng reaver
sudo apt install -y openssl stunnel4

echo "✅ Security Tools instaladas com sucesso!"
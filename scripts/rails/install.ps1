# DevForge - Ruby on Rails Installer for Windows (WSL2)
# Usage: Set-ExecutionPolicy Bypass -Scope Process; iex "& { $(irm https://rafaelferreira2312.github.io/devforge/scripts/rails/install.ps1) } 3.2"

param([string]$RubyVersion = "3.2")

Write-Host "🔧 DevForge: Instalando Ruby on Rails no Windows via WSL2..." -ForegroundColor Cyan

# Verificar WSL2
Write-Host "📦 Verificando WSL2..." -ForegroundColor Yellow
wsl --status

# Instalar Ubuntu no WSL2 se necessário
Write-Host "📦 Instalando Ubuntu no WSL2..." -ForegroundColor Cyan
wsl --install -d Ubuntu

# Executar script de instalação dentro do WSL
Write-Host "📦 Instalando Ruby $RubyVersion e Rails no WSL..." -ForegroundColor Cyan
wsl bash -c "curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/rails/install.sh | bash -s $RubyVersion"

Write-Host "✅ Ruby on Rails instalado no WSL2!" -ForegroundColor Green
Write-Host "💡 Execute 'wsl' para acessar o terminal Linux e usar rails commands." -ForegroundColor Yellow
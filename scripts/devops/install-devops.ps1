# DevForge - DevOps Tools Installer for Windows
param([string]$WSL_Distro = "Ubuntu")

Write-Host "🔧 DevForge: Instalando DevOps Tools no Windows via WSL2..." -ForegroundColor Cyan

# Verificar WSL2
wsl --status

# Instalar WSL2 se necessário
wsl --install -d $WSL_Distro

# Executar script dentro do WSL
wsl bash -c "curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/devops/install-devops.sh | bash"

Write-Host "✅ DevOps Tools instaladas no WSL2!" -ForegroundColor Green
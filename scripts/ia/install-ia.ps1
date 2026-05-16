# DevForge - IA/ML Stack Installer for Windows (WSL2)
Write-Host "🔧 DevForge: Instalando IA/ML Stack no Windows via WSL2..." -ForegroundColor Cyan

wsl --install -d Ubuntu
wsl bash -c "curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/ia/install-ia.sh | bash"

Write-Host "✅ IA/ML Stack instalada no WSL2!" -ForegroundColor Green
Write-Host "💡 Execute 'wsl' e depois 'source ~/ia-env/bin/activate' para ativar" -ForegroundColor Yellow
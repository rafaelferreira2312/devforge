# DevForge WordPress Installer for Windows (WSL2)
Write-Host "🔧 Instalando WordPress via WSL2..." -ForegroundColor Cyan
wsl --install -d Ubuntu
wsl sudo apt update && sudo apt upgrade -y
wsl bash -c "curl -fsSL https://rafaelferreira2312.github.io/devforge/scripts/wordpress/install-wordpress.sh | bash"
Write-Host "✅ WordPress instalado no WSL! Acesse http://localhost no navegador." -ForegroundColor Green
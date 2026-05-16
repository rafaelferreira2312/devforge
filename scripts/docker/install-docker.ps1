# DevForge - Docker Installer for Windows
Write-Host "🔧 DevForge: Instalando Docker Desktop no Windows..." -ForegroundColor Cyan

# Instalar via winget
Write-Host "📦 Instalando Docker Desktop..." -ForegroundColor Yellow
winget install Docker.DockerDesktop --silent --accept-package-agreements

Write-Host "✅ Docker Desktop instalado!" -ForegroundColor Green
Write-Host "💡 Reinicie o computador para concluir a instalação" -ForegroundColor Yellow
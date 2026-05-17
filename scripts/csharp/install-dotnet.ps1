# DevForge - .NET SDK Installer for Windows
# Usage: powershell -ExecutionPolicy Bypass -File install-dotnet.ps1 8.0

param([string]$DotnetVersion = "8.0")

Write-Host "🔧 DevForge: Instalando .NET SDK $DotnetVersion no Windows..." -ForegroundColor Cyan

# Instalar via winget
winget install --id Microsoft.DotNet.SDK.$DotnetVersion --silent --accept-package-agreements

# Verificar instalação
dotnet --info

Write-Host "✅ .NET SDK $DotnetVersion instalado!" -ForegroundColor Green
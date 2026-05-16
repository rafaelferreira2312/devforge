# DevForge - Node.js Installer for Windows
# Usage: Set-ExecutionPolicy Bypass -Scope Process; iex "& { $(irm https://rafaelferreira2312.github.io/devforge/scripts/nodejs/install.ps1) } 20"

param([string]$NodeVersion = "20")

Write-Host "🔧 DevForge: Instalando Node.js $NodeVersion no Windows..." -ForegroundColor Cyan

# Backup dos pacotes globais
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "📦 Fazendo backup dos pacotes npm globais..." -ForegroundColor Yellow
    npm list -g --depth=0 > "$env:USERPROFILE\npm-global-backup.txt"
    Write-Host "✅ Backup salvo" -ForegroundColor Green
}

# Usar winget para instalar
Write-Host "📦 Instalando Node.js via winget..." -ForegroundColor Cyan
winget install --id OpenJS.NodeJS --version $NodeVersion --silent --accept-package-agreements

# Adicionar ao PATH
$nodePath = "$env:ProgramFiles\nodejs"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$nodePath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$nodePath", "Machine")
    Write-Host "✅ Node.js adicionado ao PATH" -ForegroundColor Green
}

Write-Host "✅ Node.js $NodeVersion instalado!" -ForegroundColor Green
& "$nodePath\node.exe" -v
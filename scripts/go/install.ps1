# DevForge - Go Installer for Windows
# Usage: Set-ExecutionPolicy Bypass -Scope Process; iex "& { $(irm https://rafaelferreira2312.github.io/devforge/scripts/go/install.ps1) } 1.23"

param([string]$GoVersion = "1.23")

Write-Host "🔧 DevForge: Instalando Go $GoVersion no Windows..." -ForegroundColor Cyan

# Backup do GOPATH atual
if (Test-Path env:GOPATH) {
    Write-Host "📦 Fazendo backup do GOPATH atual..." -ForegroundColor Yellow
    $env:GOPATH | Out-File -FilePath "$env:USERPROFILE\go-env-backup.txt"
    Write-Host "✅ Backup salvo" -ForegroundColor Green
}

# Usar winget para instalar
Write-Host "📦 Instalando Go via winget..." -ForegroundColor Cyan
winget install --id GoLang.Go --version $GoVersion --silent --accept-package-agreements

# Configurar GOPATH
$goPath = "$env:USERPROFILE\go"
[Environment]::SetEnvironmentVariable("GOPATH", $goPath, "User")
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$goBinPath = "$env:ProgramFiles\Go\bin"
$goPathBin = "$goPath\bin"

if ($currentPath -notlike "*$goBinPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$goBinPath;$goPathBin", "User")
    Write-Host "✅ Go adicionado ao PATH" -ForegroundColor Green
}

# Criar estrutura GOPATH
New-Item -ItemType Directory -Force -Path "$goPath\src" | Out-Null
New-Item -ItemType Directory -Force -Path "$goPath\bin" | Out-Null
New-Item -ItemType Directory -Force -Path "$goPath\pkg" | Out-Null

Write-Host "✅ Go $GoVersion instalado!" -ForegroundColor Green
& "$env:ProgramFiles\Go\bin\go.exe" version
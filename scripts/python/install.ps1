# DevForge - Python Installer for Windows
# Usage: Set-ExecutionPolicy Bypass -Scope Process; iex "& { $(irm https://rafaelferreira2312.github.io/devforge/scripts/python/install.ps1) } 3.12"

param([string]$PythonVersion = "3.12")

Write-Host "🔧 DevForge: Instalando Python $PythonVersion no Windows..." -ForegroundColor Cyan

# Backup dos pacotes pip
if (Get-Command pip -ErrorAction SilentlyContinue) {
    Write-Host "📦 Fazendo backup dos pacotes pip..." -ForegroundColor Yellow
    pip freeze > "$env:USERPROFILE\pip-packages-backup.txt"
    Write-Host "✅ Backup salvo" -ForegroundColor Green
}

# Usar winget para instalar
Write-Host "📦 Instalando Python via winget..." -ForegroundColor Cyan
winget install --id Python.Python.$($PythonVersion -replace '\.', '') --silent --accept-package-agreements

# Adicionar ao PATH
$pythonPath = "$env:LocalAppData\Programs\Python\Python$(($PythonVersion -replace '\.', '') -replace '3', '3')"
$pythonScriptsPath = "$pythonPath\Scripts"

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$pythonPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$pythonPath;$pythonScriptsPath", "User")
    Write-Host "✅ Python adicionado ao PATH" -ForegroundColor Green
}

Write-Host "✅ Python $PythonVersion instalado!" -ForegroundColor Green
& "$pythonPath\python.exe" --version
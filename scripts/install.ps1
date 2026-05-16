# DevForge - PHP Installer for Windows
# Usage: Set-ExecutionPolicy Bypass -Scope Process; iex "& { $(irm https://devforge.sh/install/php.ps1) } 8.3"

param([string]$PHPVersion = "8.3")

Write-Host "🔧 DevForge: Instalando PHP $PHPVersion no Windows..." -ForegroundColor Cyan

# Verificar winget
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ winget não encontrado. Instale o App Installer da Microsoft Store." -ForegroundColor Red
    exit 1
}

# Mapear versão para winget ID
$versionMap = @{
    "8.3" = "PHP.PHP.8.3"
    "8.2" = "PHP.PHP.8.2"
    "8.1" = "PHP.PHP.8.1"
}
$wingetId = $versionMap[$PHPVersion]
if (-not $wingetId) {
    Write-Host "Versão não suportada. Use 8.3, 8.2 ou 8.1" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Instalando $wingetId via winget..."
winget install --id $wingetId --silent --accept-package-agreements

# Backup do php.ini se existir
$phpPath = "$env:ProgramFiles\PHP\$PHPVersion"
$iniFile = "$phpPath\php.ini"
if (Test-Path $iniFile) {
    $backupFile = "$iniFile.devforge.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $iniFile $backupFile
    Write-Host "✅ Backup criado: $backupFile" -ForegroundColor Green
}

# Adicionar ao PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$phpPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$phpPath", "Machine")
    Write-Host "✅ PHP adicionado ao PATH do sistema. Reinicie o terminal." -ForegroundColor Green
}

Write-Host "✅ PHP $PHPVersion instalado com sucesso!" -ForegroundColor Green
& "$phpPath\php.exe" -v

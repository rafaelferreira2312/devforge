# DevForge - Java JDK Installer for Windows
# Usage: Set-ExecutionPolicy Bypass -Scope Process; iex "& { $(irm https://rafaelferreira2312.github.io/devforge/scripts/java/install.ps1) } 21"

param([string]$JdkVersion = "21")

Write-Host "🔧 DevForge: Instalando JDK $JdkVersion no Windows..." -ForegroundColor Cyan

# Backup do JAVA_HOME atual
if (Test-Path env:JAVA_HOME) {
    Write-Host "📦 Fazendo backup do JAVA_HOME atual..." -ForegroundColor Yellow
    $env:JAVA_HOME | Out-File -FilePath "$env:USERPROFILE\java-env-backup.txt"
    Write-Host "✅ Backup salvo" -ForegroundColor Green
}

# Usar winget para instalar o Eclipse Temurin (OpenJDK)
Write-Host "📦 Instalando Eclipse Temurin JDK via winget..." -ForegroundColor Cyan
$jdkPackage = "EclipseAdoptium.Temurin.$JdkVersion"
winget install --id $jdkPackage --silent --accept-package-agreements

# Configurar JAVA_HOME
$javaPath = "C:\Program Files\Eclipse Adoptium\jdk-$JdkVersion*"
$javaHome = (Get-ChildItem $javaPath | Select-Object -First 1).FullName

[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$javaHome\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$javaHome\bin", "Machine")
    Write-Host "✅ JAVA_HOME configurado" -ForegroundColor Green
}

Write-Host "✅ JDK $JdkVersion instalado!" -ForegroundColor Green
& "$javaHome\bin\java.exe" -version
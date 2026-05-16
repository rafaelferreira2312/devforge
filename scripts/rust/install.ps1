# DevForge - Rust Installer for Windows
# Usage: Set-ExecutionPolicy Bypass -Scope Process; iex "& { $(irm https://rafaelferreira2312.github.io/devforge/scripts/rust/install.ps1) } stable"

param([string]$RustToolchain = "stable")

Write-Host "🔧 DevForge: Instalando Rust (toolchain: $RustToolchain) no Windows..." -ForegroundColor Cyan

# Backup das crates
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    Write-Host "📦 Fazendo backup das crates instaladas..." -ForegroundColor Yellow
    cargo install --list | Out-File -FilePath "$env:USERPROFILE\rust-backup.txt"
    Write-Host "✅ Backup salvo" -ForegroundColor Green
}

# Baixar e executar rustup-init.exe
Write-Host "📦 Baixando rustup-init.exe..." -ForegroundColor Cyan
$rustupUrl = "https://win.rustup.rs/x86_64"
$rustupInstaller = "$env:TEMP\rustup-init.exe"
Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupInstaller

Write-Host "📦 Instalando Rust..." -ForegroundColor Cyan
Start-Process -FilePath $rustupInstaller -ArgumentList "-y --default-toolchain $RustToolchain" -Wait -NoNewWindow

# Adicionar ao PATH do usuário
$cargoBin = "$env:USERPROFILE\.cargo\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$cargoBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$cargoBin", "User")
    Write-Host "✅ Cargo adicionado ao PATH" -ForegroundColor Green
}

Write-Host "✅ Rust instalado!" -ForegroundColor Green
& "$cargoBin\rustc.exe" --version
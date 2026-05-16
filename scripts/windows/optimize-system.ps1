# DevForge - Windows System Optimization Script
Write-Host "🔧 DevForge: Otimizando o sistema Windows..." -ForegroundColor Cyan

# Limpar arquivos temporários
Write-Host "📦 Limpando arquivos temporários..." -ForegroundColor Yellow
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Limpar cache do Windows
Write-Host "📦 Limpando cache do Windows..." -ForegroundColor Yellow
CleanMgr /sagerun:1 -ErrorAction SilentlyContinue

# Otimizar disco (defrag)
Write-Host "📦 Otimizando disco..." -ForegroundColor Yellow
Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue

# Desabilitar serviços desnecessários
Write-Host "📦 Desabilitando serviços desnecessários..." -ForegroundColor Yellow
Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue

Write-Host "✅ Sistema otimizado!" -ForegroundColor Green
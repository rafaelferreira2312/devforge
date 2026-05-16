# DevForge - Windows Security Audit Script
Write-Host "🔒 DevForge: Auditoria de segurança..." -ForegroundColor Cyan

# Verificar Windows Updates
Write-Host "📦 Updates pendentes:" -ForegroundColor Yellow
Get-WindowsUpdate -ErrorAction SilentlyContinue | Select-Object Title

# Verificar firewall
Write-Host ""
Write-Host "🔥 Status do Firewall:" -ForegroundColor Yellow
Get-NetFirewallProfile | Select-Object Name, Enabled

# Verificar usuários administradores
Write-Host ""
Write-Host "👥 Usuários Administradores:" -ForegroundColor Yellow
Get-LocalGroupMember -Group "Administrators" | Select-Object Name

Write-Host ""
Write-Host "✅ Auditoria concluída!" -ForegroundColor Green
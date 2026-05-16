# DevForge - Install Development Tools on Windows
Write-Host "🔧 DevForge: Instalando ferramentas de desenvolvimento..." -ForegroundColor Cyan

# Instalar via Winget
$tools = @(
    "Microsoft.VisualStudioCode",
    "Git.Git",
    "OpenJS.NodeJS",
    "Python.Python.3.11",
    "Docker.DockerDesktop",
    "PostgreSQL.PostgreSQL",
    "MongoDB.Server"
)

foreach ($tool in $tools) {
    Write-Host "📦 Instalando $tool..." -ForegroundColor Yellow
    winget install --id $tool --silent --accept-package-agreements
}

Write-Host "✅ Ferramentas instaladas!" -ForegroundColor Green
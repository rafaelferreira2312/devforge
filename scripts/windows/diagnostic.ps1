# DevForge - Windows Diagnostic Script
# Usage: powershell -ExecutionPolicy Bypass -File diagnostic.ps1

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           DevForge - Windows Hardware Diagnostic Tool v1.0          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ==================== COLETA DE INFORMAÇÕES ====================
Write-Host "🔍 Coletando informações do sistema..." -ForegroundColor Yellow

# Sistema Operacional
$OS = Get-WmiObject -Class Win32_OperatingSystem
$OSName = $OS.Caption
$OSVersion = $OS.Version
$OSBuild = $OS.BuildNumber

# CPU
$CPU = Get-WmiObject -Class Win32_Processor
$CPUModel = $CPU.Name
$CPUCores = $CPU.NumberOfCores
$CPUThreads = $CPU.NumberOfLogicalProcessors
$CPUMaxClock = $CPU.MaxClockSpeed

# Memória RAM
$RAM = Get-WmiObject -Class Win32_ComputerSystem
$RAMTotal = [math]::Round($RAM.TotalPhysicalMemory / 1GB, 2)
$RAMFree = Get-Counter '\Memory\Available MBytes' | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
$RAMFreeGB = [math]::Round($RAMFree / 1024, 2)
$RAMUsedGB = [math]::Round($RAMTotal - $RAMFreeGB, 2)
$RAMPercent = [math]::Round(($RAMUsedGB / $RAMTotal) * 100, 1)

# Disco
$Disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
$DiskTotal = [math]::Round($Disk.Size / 1GB, 2)
$DiskFree = [math]::Round($Disk.FreeSpace / 1GB, 2)
$DiskUsed = [math]::Round($DiskTotal - $DiskFree, 2)
$DiskPercent = [math]::Round(($DiskUsed / $DiskTotal) * 100, 1)

# GPU
$GPU = Get-WmiObject -Class Win32_VideoController | Where-Object {$_.Name -notlike "*Remote*" -and $_.Name -notlike "*Mirror*"} | Select-Object -First 1
$GPUModel = $GPU.Name
$GPURAM = [math]::Round($GPU.AdapterRAM / 1GB, 0)

# Rede
$Network = Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.*"} | Select-Object -First 1
$IPAddress = $Network.IPAddress

# Hostname
$Hostname = $env:COMPUTERNAME

# ==================== EXIBIÇÃO DOS RESULTADOS ====================
Write-Host ""
Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│                       SISTEMA OPERACIONAL                       │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host "   📀 SO: $OSName" -ForegroundColor Blue
Write-Host "   📌 Versão: $OSVersion (Build $OSBuild)" -ForegroundColor Blue
Write-Host "   💻 Hostname: $Hostname" -ForegroundColor Blue
Write-Host ""

Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│                              CPU                                 │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host "   🖥️ Modelo: $CPUModel" -ForegroundColor Blue
Write-Host "   ⚡ Núcleos: $CPUCores (Físicos) / $CPUThreads (Lógicos)" -ForegroundColor Blue
Write-Host "   🚀 Clock Máximo: ${CPUMaxClock}MHz" -ForegroundColor Blue

# Avaliação CPU
if ($CPUCores -ge 8) {
    Write-Host "   ✅ Avaliação: Excelente para qualquer stack" -ForegroundColor Green
} elseif ($CPUCores -ge 4) {
    Write-Host "   ✅ Avaliação: Bom para maioria das stacks" -ForegroundColor Green
} elseif ($CPUCores -ge 2) {
    Write-Host "   ⚠️ Avaliação: OK para tarefas básicas" -ForegroundColor Yellow
} else {
    Write-Host "   ❌ Avaliação: Limitado, recomendado upgrade" -ForegroundColor Red
}
Write-Host ""

Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│                          MEMÓRIA RAM                            │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host "   💾 Total: ${RAMTotal}GB" -ForegroundColor Blue
Write-Host "   📊 Em uso: ${RAMUsedGB}GB (${RAMPercent}%)" -ForegroundColor Blue
Write-Host "   📊 Livre: ${RAMFreeGB}GB" -ForegroundColor Blue

# Avaliação RAM
if ($RAMTotal -ge 32) {
    Write-Host "   ✅ Avaliação: Excelente para IA/ML, Containers, Big Data" -ForegroundColor Green
} elseif ($RAMTotal -ge 16) {
    Write-Host "   ✅ Avaliação: Ótimo para desenvolvimento geral" -ForegroundColor Green
} elseif ($RAMTotal -ge 8) {
    Write-Host "   ⚠️ Avaliação: Bom, mas limitado para containers/IA" -ForegroundColor Yellow
} elseif ($RAMTotal -ge 4) {
    Write-Host "   ⚠️ Avaliação: Mínimo para desenvolvimento web" -ForegroundColor Yellow
} else {
    Write-Host "   ❌ Avaliação: Insuficiente, considere upgrade" -ForegroundColor Red
}
Write-Host ""

Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│                          ARMAZENAMENTO                          │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host "   💽 Total: ${DiskTotal}GB" -ForegroundColor Blue
Write-Host "   📊 Usado: ${DiskUsed}GB (${DiskPercent}%)" -ForegroundColor Blue
Write-Host "   📊 Livre: ${DiskFree}GB" -ForegroundColor Blue

# Avaliação Disco
if ($DiskTotal -ge 1000) {
    Write-Host "   ✅ Avaliação: Excelente para projetos grandes" -ForegroundColor Green
} elseif ($DiskTotal -ge 256) {
    Write-Host "   ✅ Avaliação: Suficiente para desenvolvimento" -ForegroundColor Green
} elseif ($DiskTotal -ge 128) {
    Write-Host "   ⚠️ Avaliação: OK, mas gerencie espaço" -ForegroundColor Yellow
} else {
    Write-Host "   ❌ Avaliação: Espaço limitado" -ForegroundColor Red
}

if ($DiskPercent -gt 85) {
    Write-Host "   ⚠️ Atenção: Disco quase cheio! Limpeza recomendada." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│                              GPU                                 │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host "   🎮 GPU: $GPUModel" -ForegroundColor Blue
Write-Host "   💾 VRAM: ${GPURAM}GB" -ForegroundColor Blue

if ($GPUModel -match "NVIDIA") {
    Write-Host "   ✅ Avaliação: Ideal para Deep Learning e IA (CUDA)" -ForegroundColor Green
} elseif ($GPUModel -match "AMD") {
    Write-Host "   ⚠️ Avaliação: OK para jogos, limitado para ML" -ForegroundColor Yellow
} else {
    Write-Host "   ⚠️ Avaliação: Sem GPU dedicada - CPU-only mode" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│                             REDE                                 │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host "   🌐 IP Local: $IPAddress" -ForegroundColor Blue
Write-Host ""

# ==================== SOFTWARE INSTALADO ====================
Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│                    SOFTWARE INSTALADO                           │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green

function Check-Software {
    param($Command, $Name)
    try {
        $result = & $Command 2>$null
        if ($result) {
            Write-Host "   ✅ $Name instalado" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ $Name não instalado" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ $Name não instalado" -ForegroundColor Red
        return $false
    }
}

Check-Software "python --version" "Python"
Check-Software "node --version" "Node.js"
Check-Software "npm --version" "npm"
Check-Software "docker --version" "Docker"
Check-Software "git --version" "Git"
Check-Software "code --version" "VS Code"
Write-Host ""

# ==================== RECOMENDAÇÃO DE STACK ====================
Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "│                 🚀 RECOMENDAÇÃO DE STACK 🚀                       │" -ForegroundColor Green
Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green

$Score = 0
$MaxScore = 10

# CPU Score
if ($CPUCores -ge 8) { $Score += 3 }
elseif ($CPUCores -ge 4) { $Score += 2 }
elseif ($CPUCores -ge 2) { $Score += 1 }

# RAM Score
if ($RAMTotal -ge 32) { $Score += 4 }
elseif ($RAMTotal -ge 16) { $Score += 3 }
elseif ($RAMTotal -ge 8) { $Score += 2 }
elseif ($RAMTotal -ge 4) { $Score += 1 }

# Disk Score
if ($DiskTotal -ge 500) { $Score += 3 }
elseif ($DiskTotal -ge 200) { $Score += 2 }
elseif ($DiskTotal -ge 100) { $Score += 1 }

Write-Host "   📊 Pontuação geral: $Score / $MaxScore" -ForegroundColor Blue
Write-Host ""

if ($Score -ge 8) {
    Write-Host "   🎯 SUA MÁQUINA É POWER USER!" -ForegroundColor Green
    Write-Host "   ✅ Recomendado para:"
    Write-Host "      • DevOps (Kubernetes, Docker, Terraform)" -ForegroundColor Blue
    Write-Host "      • IA/ML (TensorFlow, PyTorch com GPU)" -ForegroundColor Blue
    Write-Host "      • Big Data (Spark, Hadoop)" -ForegroundColor Blue
    Write-Host "      • Múltiplos containers simultaneamente" -ForegroundColor Blue
} elseif ($Score -ge 6) {
    Write-Host "   🎯 MÁQUINA DE DESENVOLVEDOR PROFISSIONAL" -ForegroundColor Green
    Write-Host "   ✅ Recomendado para:"
    Write-Host "      • Backend (Node.js, Python, Java, Go, Rust)" -ForegroundColor Blue
    Write-Host "      • Frontend (React, Vue, Angular)" -ForegroundColor Blue
    Write-Host "      • Mobile (React Native, Flutter)" -ForegroundColor Blue
    Write-Host "      • Docker (até 5 containers simultâneos)" -ForegroundColor Blue
} elseif ($Score -ge 4) {
    Write-Host "   🎯 MÁQUINA DE ESTUDOS / INICIANTE" -ForegroundColor Yellow
    Write-Host "   ✅ Recomendado para:"
    Write-Host "      • Web Development (PHP, Node.js, Python)" -ForegroundColor Blue
    Write-Host "      • Scripts e automação" -ForegroundColor Blue
    Write-Host "      • Estudos de programação" -ForegroundColor Blue
    Write-Host "      • ⚠️ Evite containers pesados" -ForegroundColor Yellow
} else {
    Write-Host "   🎯 MÁQUINA BÁSICA / LEGACY" -ForegroundColor Red
    Write-Host "   ✅ Recomendado para:"
    Write-Host "      • Terminal / CLI tools" -ForegroundColor Blue
    Write-Host "      • Frontend simples" -ForegroundColor Blue
    Write-Host "      • Automação básica" -ForegroundColor Blue
    Write-Host "      • ⚠️ Considere upgrade para melhor experiência" -ForegroundColor Red
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ Diagnóstico concluído!" -ForegroundColor Green
Write-Host "💡 Dica: Execute 'optimize-system.ps1' para melhorar performance" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
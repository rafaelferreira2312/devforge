# DevForge - Windows Diagnostic Script
# Encoding: UTF-8 with BOM
# Usage: powershell -ExecutionPolicy Bypass -File diagnostic.ps1
# Or: powershell -ExecutionPolicy Bypass -Command "iex (irm https://rafaelferreira2312.github.io/devforge/scripts/windows/diagnostic.ps1)"

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "           DevForge - Windows Hardware Diagnostic Tool v1.0" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# ==================== COLETA DE INFORMACOES ====================
Write-Host "Coletando informacoes do sistema..." -ForegroundColor Yellow

# Sistema Operacional
$OS = Get-CimInstance -ClassName Win32_OperatingSystem
$OSName = $OS.Caption
$OSVersion = $OS.Version
$OSBuild = $OS.BuildNumber

# CPU
$CPU = Get-CimInstance -ClassName Win32_Processor
$CPUModel = $CPU.Name
$CPUCores = $CPU.NumberOfCores
$CPUThreads = $CPU.NumberOfLogicalProcessors
$CPUMaxClock = $CPU.MaxClockSpeed

# Memoria RAM (usando CIM ao inves de Get-Counter)
$RAM = Get-CimInstance -ClassName Win32_ComputerSystem
$RAMTotal = [math]::Round($RAM.TotalPhysicalMemory / 1GB, 2)

# Calcular uso de memoria via Performance Counter alternativo
try {
    $MemAvailable = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Memory | Select-Object -ExpandProperty AvailableBytes
    $MemAvailableGB = [math]::Round($MemAvailable / 1GB, 2)
    $RAMUsedGB = [math]::Round($RAMTotal - $MemAvailableGB, 2)
    $RAMPercent = [math]::Round(($RAMUsedGB / $RAMTotal) * 100, 1)
    $RAMFreeGB = $MemAvailableGB
} catch {
    # Fallback: usar valores aproximados
    $RAMUsedGB = [math]::Round($RAMTotal * 0.5, 2)
    $RAMPercent = 50
    $RAMFreeGB = [math]::Round($RAMTotal * 0.5, 2)
}

# Disco
$Disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
$DiskTotal = [math]::Round($Disk.Size / 1GB, 2)
$DiskFree = [math]::Round($Disk.FreeSpace / 1GB, 2)
$DiskUsed = [math]::Round($DiskTotal - $DiskFree, 2)
$DiskPercent = [math]::Round(($DiskUsed / $DiskTotal) * 100, 1)

# GPU
$GPU = Get-CimInstance -ClassName Win32_VideoController | Where-Object {$_.Name -notlike "*Remote*" -and $_.Name -notlike "*Mirror*"} | Select-Object -First 1
$GPUModel = $GPU.Name
if ($GPU.AdapterRAM) {
    $GPURAM = [math]::Round($GPU.AdapterRAM / 1GB, 0)
} else {
    $GPURAM = 0
}

# Rede
$Network = Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.*"} | Select-Object -First 1
$IPAddress = $Network.IPAddress

# Hostname
$Hostname = $env:COMPUTERNAME

# ==================== EXIBICAO DOS RESULTADOS ====================
Write-Host ""
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                       SISTEMA OPERACIONAL" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "   SO: $OSName" -ForegroundColor Blue
Write-Host "   Versao: $OSVersion (Build $OSBuild)" -ForegroundColor Blue
Write-Host "   Hostname: $Hostname" -ForegroundColor Blue
Write-Host ""

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                              CPU" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "   Modelo: $CPUModel" -ForegroundColor Blue
Write-Host "   Nucleos: $CPUCores (Fisicos) / $CPUThreads (Logicos)" -ForegroundColor Blue
Write-Host "   Clock Maximo: ${CPUMaxClock}MHz" -ForegroundColor Blue

# Avaliacao CPU
if ($CPUCores -ge 8) {
    Write-Host "   [OK] Avaliacao: Excelente para qualquer stack" -ForegroundColor Green
} elseif ($CPUCores -ge 4) {
    Write-Host "   [OK] Avaliacao: Bom para maioria das stacks" -ForegroundColor Green
} elseif ($CPUCores -ge 2) {
    Write-Host "   [!] Avaliacao: OK para tarefas basicas" -ForegroundColor Yellow
} else {
    Write-Host "   [X] Avaliacao: Limitado, recomendado upgrade" -ForegroundColor Red
}
Write-Host ""

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                          MEMORIA RAM" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "   Total: ${RAMTotal}GB" -ForegroundColor Blue
Write-Host "   Em uso: ${RAMUsedGB}GB (${RAMPercent}%)" -ForegroundColor Blue
Write-Host "   Livre: ${RAMFreeGB}GB" -ForegroundColor Blue

# Avaliacao RAM
if ($RAMTotal -ge 32) {
    Write-Host "   [OK] Avaliacao: Excelente para IA/ML, Containers, Big Data" -ForegroundColor Green
} elseif ($RAMTotal -ge 16) {
    Write-Host "   [OK] Avaliacao: Otimo para desenvolvimento geral" -ForegroundColor Green
} elseif ($RAMTotal -ge 8) {
    Write-Host "   [!] Avaliacao: Bom, mas limitado para containers/IA" -ForegroundColor Yellow
} elseif ($RAMTotal -ge 4) {
    Write-Host "   [!] Avaliacao: Minimo para desenvolvimento web" -ForegroundColor Yellow
} else {
    Write-Host "   [X] Avaliacao: Insuficiente, considere upgrade" -ForegroundColor Red
}
Write-Host ""

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                          ARMAZENAMENTO" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "   Total: ${DiskTotal}GB" -ForegroundColor Blue
Write-Host "   Usado: ${DiskUsed}GB (${DiskPercent}%)" -ForegroundColor Blue
Write-Host "   Livre: ${DiskFree}GB" -ForegroundColor Blue

# Avaliacao Disco
if ($DiskTotal -ge 1000) {
    Write-Host "   [OK] Avaliacao: Excelente para projetos grandes" -ForegroundColor Green
} elseif ($DiskTotal -ge 256) {
    Write-Host "   [OK] Avaliacao: Suficiente para desenvolvimento" -ForegroundColor Green
} elseif ($DiskTotal -ge 128) {
    Write-Host "   [!] Avaliacao: OK, mas gerencie espaco" -ForegroundColor Yellow
} else {
    Write-Host "   [X] Avaliacao: Espaco limitado" -ForegroundColor Red
}

if ($DiskPercent -gt 85) {
    Write-Host "   [!] Atencao: Disco quase cheio! Limpeza recomendada." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                              GPU" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "   GPU: $GPUModel" -ForegroundColor Blue
if ($GPURAM -gt 0) {
    Write-Host "   VRAM: ${GPURAM}GB" -ForegroundColor Blue
} else {
    Write-Host "   VRAM: Nao disponivel" -ForegroundColor Blue
}

if ($GPUModel -match "NVIDIA") {
    Write-Host "   [OK] Avaliacao: Ideal para Deep Learning e IA (CUDA)" -ForegroundColor Green
} elseif ($GPUModel -match "AMD") {
    Write-Host "   [!] Avaliacao: OK para jogos, limitado para ML" -ForegroundColor Yellow
} else {
    Write-Host "   [!] Avaliacao: Sem GPU dedicada - CPU-only mode" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                             REDE" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "   IP Local: $IPAddress" -ForegroundColor Blue
Write-Host ""

# ==================== SOFTWARE INSTALADO ====================
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                    SOFTWARE INSTALADO" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green

function Check-Software {
    param($Command, $Name)
    try {
        $result = Invoke-Expression "$Command" 2>$null
        if ($result) {
            Write-Host "   [OK] $Name instalado" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   [X] $Name nao instalado" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   [X] $Name nao instalado" -ForegroundColor Red
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

# ==================== RECOMENDACAO DE STACK ====================
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                 RECOMENDACAO DE STACK" -ForegroundColor Green
Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Green

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

Write-Host "   Pontuacao geral: $Score / $MaxScore" -ForegroundColor Blue
Write-Host ""

if ($Score -ge 8) {
    Write-Host "   [POWER USER] SUA MAQUINA E POWER USER!" -ForegroundColor Green
    Write-Host "   Recomendado para:"
    Write-Host "      - DevOps (Kubernetes, Docker, Terraform)" -ForegroundColor Blue
    Write-Host "      - IA/ML (TensorFlow, PyTorch com GPU)" -ForegroundColor Blue
    Write-Host "      - Big Data (Spark, Hadoop)" -ForegroundColor Blue
    Write-Host "      - Multiplos containers simultaneamente" -ForegroundColor Blue
} elseif ($Score -ge 6) {
    Write-Host "   [PRO] MAQUINA DE DESENVOLVEDOR PROFISSIONAL" -ForegroundColor Green
    Write-Host "   Recomendado para:"
    Write-Host "      - Backend (Node.js, Python, Java, Go, Rust)" -ForegroundColor Blue
    Write-Host "      - Frontend (React, Vue, Angular)" -ForegroundColor Blue
    Write-Host "      - Mobile (React Native, Flutter)" -ForegroundColor Blue
    Write-Host "      - Docker (ate 5 containers simultaneos)" -ForegroundColor Blue
} elseif ($Score -ge 4) {
    Write-Host "   [STUDENT] MAQUINA DE ESTUDOS / INICIANTE" -ForegroundColor Yellow
    Write-Host "   Recomendado para:"
    Write-Host "      - Web Development (PHP, Node.js, Python)" -ForegroundColor Blue
    Write-Host "      - Scripts e automacao" -ForegroundColor Blue
    Write-Host "      - Estudos de programacao" -ForegroundColor Blue
    Write-Host "      - [!] Evite containers pesados" -ForegroundColor Yellow
} else {
    Write-Host "   [BASIC] MAQUINA BASICA / LEGACY" -ForegroundColor Red
    Write-Host "   Recomendado para:"
    Write-Host "      - Terminal / CLI tools" -ForegroundColor Blue
    Write-Host "      - Frontend simples" -ForegroundColor Blue
    Write-Host "      - Automacao basica" -ForegroundColor Blue
    Write-Host "      - [!] Considere upgrade para melhor experiencia" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "[OK] Diagnostico concluido!" -ForegroundColor Green
Write-Host "[DICA] Execute 'optimize-system.ps1' para melhorar performance" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan
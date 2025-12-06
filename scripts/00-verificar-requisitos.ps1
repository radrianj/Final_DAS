# Script: Verificar que todo el software necesario está instalado
# Propósito: Evitar errores por falta de dependencias

Write-Host "=== VERIFICACION DE REQUISITOS ===" -ForegroundColor Cyan
Write-Host ""

# Array para almacenar resultados
$requisitos = @()

# Verificar Docker
Write-Host "Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $requisitos += "OK|Docker: $dockerVersion"
    } else {
        $requisitos += "ERROR|Docker: NO INSTALADO"
    }
    
    # Verificar que Docker está corriendo
    docker ps > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $requisitos += "OK|Docker daemon: Activo"
    } else {
        $requisitos += "ERROR|Docker daemon: NO esta corriendo. INICIA DOCKER DESKTOP."
    }
} catch {
    $requisitos += "ERROR|Docker: NO INSTALADO - https://www.docker.com/products/docker-desktop/"
}

# Verificar Minikube
Write-Host "Verificando Minikube..." -ForegroundColor Yellow
try {
    $minikubeVersion = minikube version --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        $requisitos += "OK|Minikube: $minikubeVersion"
    } else {
        throw "Minikube no encontrado"
    }
} catch {
    $requisitos += "ERROR|Minikube: NO INSTALADO - https://minikube.sigs.k8s.io/docs/start/"
}

# Verificar kubectl
Write-Host "Verificando kubectl..." -ForegroundColor Yellow
try {
    $kubectlOutput = kubectl version --client 2>&1 | Out-String
    if ($kubectlOutput -match "Client Version: (v[\d\.]+)") {
        $requisitos += "OK|kubectl: $($matches[1])"
    } else {
        throw "kubectl no encontrado"
    }
} catch {
    $requisitos += "ERROR|kubectl: NO INSTALADO - https://kubernetes.io/docs/tasks/tools/"
}

# Verificar Helm
Write-Host "Verificando Helm..." -ForegroundColor Yellow
try {
    $helmVersion = helm version --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        $requisitos += "OK|Helm: $helmVersion"
    } else {
        throw "Helm no encontrado"
    }
} catch {
    $requisitos += "ERROR|Helm: NO INSTALADO - https://helm.sh/docs/intro/install/"
}

# Verificar K6 (opcional)
Write-Host "Verificando K6..." -ForegroundColor Yellow
try {
    $k6Output = k6 version 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        $requisitos += "OK|K6: instalado correctamente"
    } else {
        throw "K6 no encontrado"
    }
} catch {
    $requisitos += "WARN|K6: NO INSTALADO (opcional para RETO 01)"
}

# Mostrar resumen
Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
foreach ($req in $requisitos) {
    $parts = $req -split '\|'
    $status = $parts[0]
    $message = $parts[1]
    
    switch ($status) {
        "OK" { Write-Host "[OK] $message" -ForegroundColor Green }
        "ERROR" { Write-Host "[ERROR] $message" -ForegroundColor Red }
        "WARN" { Write-Host "[WARN] $message" -ForegroundColor Yellow }
    }
}

# Verificar si hay errores críticos
$erroresCriticos = $requisitos | Where-Object { $_ -like "ERROR|*" }
if ($erroresCriticos.Count -gt 0) {
    Write-Host ""
    Write-Host "[ERROR] FALTAN REQUISITOS CRITICOS. Instalados antes de continuar." -ForegroundColor Red
    exit 1
} else {
    Write-Host ""
    Write-Host "[OK] TODOS LOS REQUISITOS CUMPLIDOS. Puedes continuar." -ForegroundColor Green
    
    # Mostrar advertencias si las hay
    $advertencias = $requisitos | Where-Object { $_ -like "WARN|*" }
    if ($advertencias.Count -gt 0) {
        Write-Host ""
        Write-Host "NOTA: K6 es opcional. El sistema funcionara sin el." -ForegroundColor Yellow
    }
    
    exit 0
}

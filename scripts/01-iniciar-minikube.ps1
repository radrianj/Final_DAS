# Script: Iniciar Minikube con configuración óptima
# Propósito: Levantar el clúster de Kubernetes local

Write-Host "=== INICIANDO MINIKUBE ===" -ForegroundColor Cyan
Write-Host ""

# Verificar si Minikube ya está corriendo
$minikubeStatus = minikube status 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[AVISO] Minikube ya esta corriendo." -ForegroundColor Yellow
    Write-Host "Deseas reiniciarlo? (S/N): " -NoNewline -ForegroundColor Yellow
    $respuesta = Read-Host
    
    if ($respuesta -eq "S" -or $respuesta -eq "s") {
        Write-Host "Deteniendo Minikube actual..." -ForegroundColor Yellow
        minikube stop
        minikube delete --all --purge
    } else {
        Write-Host "Usando Minikube existente." -ForegroundColor Green
        minikube status
        exit 0
    }
}

# Configuración de recursos (AJUSTA según tu PC)
$CPUS = 4            # Número de CPUs (mínimo 2, recomendado 4)
$MEMORY = 8192       # Memoria en MB (mínimo 4096, recomendado 8192)
$DISK_SIZE = "20g"   # Tamaño del disco
$K8S_VERSION = "v1.28.0"  # Versión estable de Kubernetes

Write-Host "Configuracion:" -ForegroundColor Cyan
Write-Host "  - CPUs: $CPUS"
Write-Host "  - Memoria: $MEMORY MB"
Write-Host "  - Disco: $DISK_SIZE"
Write-Host "  - Kubernetes: $K8S_VERSION"
Write-Host ""

# Iniciar Minikube
Write-Host "Iniciando Minikube (esto puede tomar 2-5 minutos)..." -ForegroundColor Yellow
minikube start `
    --driver=docker `
    --cpus=$CPUS `
    --memory=$MEMORY `
    --disk-size=$DISK_SIZE `
    --kubernetes-version=$K8S_VERSION `
    --wait-timeout=10m `
    --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al iniciar Minikube." -ForegroundColor Red
    Write-Host "Intentando con configuracion reducida..." -ForegroundColor Yellow
    
    minikube delete --all
    minikube start `
        --driver=docker `
        --cpus=2 `
        --memory=4096 `
        --kubernetes-version=$K8S_VERSION
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] No se pudo iniciar Minikube. Verifica Docker Desktop." -ForegroundColor Red
        exit 1
    }
}

# Habilitar addons esenciales
Write-Host ""
Write-Host "Habilitando addons de Minikube..." -ForegroundColor Yellow

Write-Host "  - Habilitando Ingress Controller..." -ForegroundColor Cyan
minikube addons enable ingress

Write-Host "  - Habilitando Metrics Server..." -ForegroundColor Cyan
minikube addons enable metrics-server

# Verificar estado
Write-Host ""
Write-Host "=== VERIFICACION ===" -ForegroundColor Cyan
minikube status
kubectl get nodes

Write-Host ""
Write-Host "[OK] Minikube iniciado correctamente." -ForegroundColor Green
Write-Host ""
Write-Host "Comandos utiles:" -ForegroundColor Yellow
Write-Host "  - Ver estado: minikube status"
Write-Host "  - Detener: minikube stop"
Write-Host "  - Eliminar: minikube delete"
Write-Host "  - Dashboard: minikube dashboard"

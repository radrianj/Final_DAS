# Script: Desplegar microservicios en Kubernetes
# Propósito: Aplicar todos los manifiestos de k8s

Write-Host "=== DESPLEGANDO MICROSERVICIOS ===" -ForegroundColor Cyan
Write-Host ""

# Verificar que Minikube está corriendo
minikube status > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Minikube no esta corriendo." -ForegroundColor Red
    exit 1
}

# Aplicar manifiestos
Write-Host "Aplicando manifiestos de Kubernetes..." -ForegroundColor Yellow
Write-Host ""

# Desplegar microservicios (solo archivos principales)
$manifests = @(
    "ms-auth.yaml",
    "ms-usuarios.yaml",
    "ms-agenda.yaml",
    "ms-tutorias.yaml",
    "ms-notificaciones.yaml",
    "client-mobile-sim.yaml",
    "tracking-dashboard.yaml"
)

foreach ($manifest in $manifests) {
    $path = "kubernetes-manifests/$manifest"
    
    if (Test-Path $path) {
        Write-Host "  - Aplicando $manifest..." -ForegroundColor Cyan
        kubectl apply -f $path
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Error al aplicar $manifest" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "[WARN] No se encontro $manifest" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[OK] Microservicios desplegados." -ForegroundColor Green

# Desplegar Ingress
Write-Host ""
Write-Host "=== DESPLEGANDO INGRESS ===" -ForegroundColor Cyan

$ingressFiles = @(
    "kubernetes-manifests/kong-ingress.yaml",
    "kubernetes-manifests/public-ingress.yaml",
    "kubernetes-manifests/protected-ingress.yaml"
)

foreach ($ingress in $ingressFiles) {
    if (Test-Path $ingress) {
        Write-Host "  - Aplicando $ingress..." -ForegroundColor Cyan
        kubectl apply -f $ingress
    } else {
        Write-Host "[WARN] No se encontro $ingress" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[OK] Ingress configurado." -ForegroundColor Green

# Verificar despliegue
Write-Host ""
Write-Host "=== VERIFICANDO DESPLIEGUE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Deployments:" -ForegroundColor Yellow
kubectl get deployments

Write-Host ""
Write-Host "Services:" -ForegroundColor Yellow
kubectl get services

Write-Host ""
Write-Host "Pods:" -ForegroundColor Yellow
kubectl get pods

Write-Host ""
Write-Host "[OK] Despliegue completado." -ForegroundColor Green
Write-Host ""
Write-Host "Espera 2-3 minutos a que todos los pods esten Running." -ForegroundColor Yellow
Write-Host "Verifica con: kubectl get pods -w" -ForegroundColor Yellow

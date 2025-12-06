# Script: Instalar dependencias con Helm
# Propósito: PostgreSQL, RabbitMQ, Kong, Prometheus/Grafana

Write-Host "=== INSTALANDO DEPENDENCIAS CON HELM ===" -ForegroundColor Cyan
Write-Host ""

# Verificar que Minikube está corriendo
minikube status > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Minikube no esta corriendo. Ejecuta 01-iniciar-minikube.ps1 primero." -ForegroundColor Red
    exit 1
}

# Agregar repositorios de Helm
Write-Host "Agregando repositorios de Helm..." -ForegroundColor Yellow

Write-Host "  - Agregando Bitnami..." -ForegroundColor Cyan
helm repo add bitnami https://charts.bitnami.com/bitnami

Write-Host "  - Agregando Kong..." -ForegroundColor Cyan
helm repo add kong https://charts.konghq.com

Write-Host "  - Agregando Prometheus Community..." -ForegroundColor Cyan
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

Write-Host "  - Actualizando repositorios..." -ForegroundColor Cyan
helm repo update

Write-Host ""
Write-Host "[OK] Repositorios agregados correctamente." -ForegroundColor Green

# CAMBIO: INSTALAR PROMETHEUS PRIMERO (para crear los CRDs de ServiceMonitor)
Write-Host ""
Write-Host "=== INSTALANDO PROMETHEUS + GRAFANA ===" -ForegroundColor Cyan
Write-Host "NOTA: Se instala primero para crear los Custom Resource Definitions (CRDs)" -ForegroundColor Yellow
helm install kube-prometheus prometheus-community/kube-prometheus-stack `
    -f helm-values/kube-prometheus-values.yaml `
    --namespace monitoring `
    --create-namespace `
    --wait --timeout 10m

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al instalar Prometheus/Grafana." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Prometheus + Grafana instalados." -ForegroundColor Green

# Esperar a que los CRDs estén disponibles
Write-Host ""
Write-Host "Esperando 30 segundos a que los CRDs esten disponibles..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Instalar PostgreSQL
Write-Host ""
Write-Host "=== INSTALANDO POSTGRESQL ===" -ForegroundColor Cyan
helm install postgresql bitnami/postgresql `
    -f helm-values/postgresql-values.yaml `
    --namespace default `
    --wait --timeout 5m

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al instalar PostgreSQL." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] PostgreSQL instalado." -ForegroundColor Green

# Instalar RabbitMQ (usando imagen oficial)
Write-Host ""
Write-Host "=== INSTALANDO RABBITMQ (OFICIAL) ===" -ForegroundColor Cyan
kubectl apply -f k8s/rabbitmq-deployment.yaml
Start-Sleep -Seconds 60
kubectl exec -n default deployment/rabbitmq -- rabbitmq-plugins enable rabbitmq_prometheus

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al instalar RabbitMQ." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] RabbitMQ instalado." -ForegroundColor Green

# Instalar Kong
Write-Host ""
Write-Host "=== INSTALANDO KONG API GATEWAY ===" -ForegroundColor Cyan
helm install kong kong/kong `
    -f helm-values/kong-values.yaml `
    --namespace default `
    --wait --timeout 5m

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al instalar Kong." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Kong instalado." -ForegroundColor Green

# Verificar instalaciones
Write-Host ""
Write-Host "=== VERIFICANDO INSTALACIONES ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pods en namespace default:" -ForegroundColor Yellow
kubectl get pods -n default

Write-Host ""
Write-Host "Pods en namespace monitoring:" -ForegroundColor Yellow
kubectl get pods -n monitoring

Write-Host ""
Write-Host "[OK] Todas las dependencias instaladas correctamente." -ForegroundColor Green
Write-Host ""
Write-Host "Espera 2-3 minutos a que todos los pods esten en estado Running." -ForegroundColor Yellow
Write-Host "Puedes verificar con: kubectl get pods --all-namespaces -w" -ForegroundColor Yellow

# Script: Construir imágenes Docker de los microservicios
# Propósito: Crear imágenes locales para desarrollo

Write-Host "=== CONSTRUYENDO IMAGENES DOCKER ===" -ForegroundColor Cyan
Write-Host ""

# Configurar Docker para usar el registry de Minikube
Write-Host "Configurando entorno Docker para Minikube..." -ForegroundColor Yellow
& minikube docker-env --shell powershell | Invoke-Expression

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] No se pudo configurar Docker para Minikube." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Entorno configurado." -ForegroundColor Green
Write-Host ""

# Lista de microservicios a construir
$microservicios = @(
    "ms-auth",
    "ms-usuarios",
    "ms-agenda",
    "ms-tutorias",
    "ms-notificaciones",
    "client-mobile-sim",
    "tracking-dashboard"
)

# Construir cada microservicio
foreach ($ms in $microservicios) {
    Write-Host "=== CONSTRUYENDO: $ms ===" -ForegroundColor Cyan
    
    if (Test-Path $ms) {
        Set-Location $ms
        
        Write-Host "  - Construyendo imagen..." -ForegroundColor Yellow
        docker build -t ${ms}:latest .
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Error al construir $ms" -ForegroundColor Red
            Set-Location ..
            exit 1
        }
        
        Write-Host "[OK] $ms construido correctamente." -ForegroundColor Green
        Set-Location ..
    } else {
        Write-Host "[WARN] Carpeta $ms no encontrada. Omitiendo..." -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Listar imágenes creadas
Write-Host "=== IMAGENES CREADAS ===" -ForegroundColor Cyan
docker images | Select-String "ms-|client-|tracking-"

Write-Host ""
Write-Host "[OK] Todas las imagenes construidas correctamente." -ForegroundColor Green
Write-Host ""
Write-Host "NOTA: Si usas estas imagenes locales, asegurate de cambiar" -ForegroundColor Yellow
Write-Host "      'imagePullPolicy: Always' a 'imagePullPolicy: Never'" -ForegroundColor Yellow
Write-Host "      en los manifiestos de Kubernetes." -ForegroundColor Yellow

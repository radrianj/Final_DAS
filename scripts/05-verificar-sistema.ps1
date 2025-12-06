# Script: Verificar que todo el sistema está funcionando
# Propósito: Diagnóstico completo del estado del clúster

Write-Host "=== VERIFICACION DEL SISTEMA ===" -ForegroundColor Cyan
Write-Host ""

# Verificar Minikube
Write-Host "=== ESTADO DE MINIKUBE ===" -ForegroundColor Yellow
minikube status
Write-Host ""

# Verificar nodos
Write-Host "=== NODOS ===" -ForegroundColor Yellow
kubectl get nodes
Write-Host ""

# Verificar pods en todos los namespaces
Write-Host "=== PODS (TODOS LOS NAMESPACES) ===" -ForegroundColor Yellow
kubectl get pods --all-namespaces
Write-Host ""

# Verificar deployments
Write-Host "=== DEPLOYMENTS ===" -ForegroundColor Yellow
kubectl get deployments
Write-Host ""

# Verificar services
Write-Host "=== SERVICES ===" -ForegroundColor Yellow
kubectl get services
Write-Host ""

# Verificar ingress
Write-Host "=== INGRESS ===" -ForegroundColor Yellow
kubectl get ingress
Write-Host ""

# Verificar releases de Helm
Write-Host "=== RELEASES DE HELM ===" -ForegroundColor Yellow
helm list --all-namespaces
Write-Host ""

# Verificar pods con problemas
Write-Host "=== PODS CON PROBLEMAS ===" -ForegroundColor Yellow
$problemPods = kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded 2>$null

if ($problemPods) {
    Write-Host $problemPods -ForegroundColor Red
} else {
    Write-Host "[OK] No hay pods con problemas." -ForegroundColor Green
}
Write-Host ""

# URLs de acceso
Write-Host "=== URLS DE ACCESO ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para acceder a los servicios, ejecuta en otra terminal:" -ForegroundColor Yellow
Write-Host "  minikube tunnel" -ForegroundColor White
Write-Host ""
Write-Host "Grafana Dashboard:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80" -ForegroundColor White
Write-Host "  http://localhost:3000" -ForegroundColor Cyan
Write-Host "  Usuario: admin" -ForegroundColor White
Write-Host "  Password: prom-operator" -ForegroundColor White
Write-Host ""
Write-Host "Prometheus:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n monitoring svc/kube-prometheus-kube-prome-prometheus 9090:9090" -ForegroundColor White
Write-Host "  http://localhost:9090" -ForegroundColor Cyan
Write-Host ""
Write-Host "RabbitMQ Management:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/rabbitmq 15672:15672" -ForegroundColor White
Write-Host "  http://localhost:15672" -ForegroundColor Cyan
Write-Host "  Usuario: user" -ForegroundColor White
Write-Host "  Password: password" -ForegroundColor White
Write-Host ""

Write-Host "[OK] Verificacion completada." -ForegroundColor Green

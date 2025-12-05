import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 2000,
  duration: '45s', 
  thresholds: {
    'http_req_failed': ['rate<0.05'], 
  },
};

export default function () {
  const url = 'http://localhost:9999/tutorias'; // URL del port-forward

  const payload = JSON.stringify({
    // 1. Datos del Solicitante
    "idEstudiante": "e12345", // Asumiendo que este ID existe
    
    // 2. Datos de la Tutoría (NOT NULL/Requeridos)
    "idTutor": "t09876",
    "materia": "Física Cuántica",
    "fecha": "2025-12-20T10:00:00Z",
    "duracionMinutos": 60,
    
    // 💡 CORRECCIÓN CRÍTICA: Campo NOT NULL faltante
    "estado": "PENDIENTE" 
  });

  const params = { headers: { 'Content-Type': 'application/json' } };
  http.post(url, payload, params);
  sleep(0.1); 
}
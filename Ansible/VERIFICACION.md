# Guía de Verificación de Servicios

Esta guía te ayudará a verificar que todos los servicios están funcionando correctamente después de ejecutar el playbook.

## Verificación Rápida (Script Automatizado)

### Opción 1: Script de Verificación

```bash
# Desde WSL o Linux
cd Ansible
chmod +x verify-services.sh
./verify-services.sh [VM_IP] [USER]

# Ejemplo:
./verify-services.sh 158.23.84.89 adminuser
```

El script verificará:
- ✅ Contenedores Docker corriendo
- ✅ Servicios HTTP respondiendo
- ✅ Estado de Docker Compose
- ✅ Recursos del sistema (memoria, disco)

## Verificación Manual

### 1. Verificar Contenedores Docker

```bash
# Conectarse a la VM
ssh adminuser@158.23.84.89

# Ver todos los contenedores
docker ps

# Ver estado de docker compose
cd ~
docker compose ps

# Ver logs de un servicio específico
docker compose logs sonarqube
docker compose logs prometheus
docker compose logs grafana
```

**Contenedores esperados:**
- `postgres` - Base de datos de SonarQube
- `sonarqube` - SonarQube
- `nginx` - Proxy reverso
- `prometheus` - Métricas
- `grafana` - Dashboards
- `alertmanager` - Alertas
- `elasticsearch` - Búsqueda de logs
- `filebeat` - Recolector de logs
- `locust-master` - Locust master
- `locust-worker` - Locust worker

### 2. Verificar Servicios HTTP

#### SonarQube
```bash
# Desde tu máquina local
curl -I http://158.23.84.89/sonar/

# O desde la VM
curl -I http://localhost:9000/sonar/
```

**Esperado:** HTTP 200 o 302 (redirección)

**Acceso web:** http://158.23.84.89/sonar/
- Usuario por defecto: `admin`
- Contraseña por defecto: `admin` (cambiar en primer inicio)

#### Prometheus
```bash
curl http://158.23.84.89/prometheus/-/healthy
```

**Esperado:** `Prometheus is Healthy.`

**Acceso web:** http://158.23.84.89/prometheus/

#### Grafana
```bash
curl http://158.23.84.89/grafana/api/health
```

**Esperado:** `{"commit":"...","database":"ok","version":"..."}`

**Acceso web:** http://158.23.84.89/grafana/
- Usuario: `admin`
- Contraseña: `admin`

#### Alertmanager
```bash
curl http://158.23.84.89/alertmanager/-/healthy
```

**Esperado:** HTTP 200

**Acceso web:** http://158.23.84.89/alertmanager/

#### Elasticsearch
```bash
curl http://158.23.84.89/elasticsearch/_cluster/health
```

**Esperado:** `{"cluster_name":"...","status":"green" o "yellow"}`

**Acceso web:** http://158.23.84.89/elasticsearch/

#### Locust
```bash
curl -I http://158.23.84.89:8089/
```

**Esperado:** HTTP 200

**Acceso web:** http://158.23.84.89:8089/

### 3. Verificar Nginx (Proxy Reverso)

```bash
# Verificar que redirige correctamente
curl -I http://158.23.84.89/

# Debería redirigir a /sonar/
```

### 4. Verificar Logs de Servicios

```bash
# Conectarse a la VM
ssh adminuser@158.23.84.89
cd ~

# Ver logs de todos los servicios
docker compose logs --tail=50

# Ver logs de un servicio específico
docker compose logs --tail=100 sonarqube
docker compose logs --tail=100 prometheus
docker compose logs --tail=100 grafana
docker compose logs --tail=100 elasticsearch

# Ver logs en tiempo real
docker compose logs -f
```

### 5. Verificar Recursos del Sistema

```bash
# Ver uso de memoria
free -h

# Ver uso de disco
df -h

# Ver uso de CPU
top

# Ver contenedores y su uso de recursos
docker stats --no-stream
```

### 6. Verificar Volúmenes Docker

```bash
# Ver volúmenes creados
docker volume ls

# Verificar tamaño de volúmenes
docker system df -v
```

## Verificación Específica por Servicio

### SonarQube

1. **Acceder a la interfaz web:**
   ```
   http://158.23.84.89/sonar/
   ```

2. **Verificar que está funcionando:**
   ```bash
   curl http://158.23.84.89/sonar/api/system/status
   ```
   Debería retornar: `{"status":"UP",...}`

3. **Ver logs si hay problemas:**
   ```bash
   docker compose logs sonarqube | tail -50
   ```

### Prometheus

1. **Verificar targets:**
   ```
   http://158.23.84.89/prometheus/targets
   ```
   Debería mostrar los targets configurados (prometheus, grafana, alertmanager)

2. **Verificar métricas:**
   ```bash
   curl http://158.23.84.89/prometheus/api/v1/query?query=up
   ```

3. **Verificar configuración:**
   ```bash
   curl http://158.23.84.89/prometheus/api/v1/status/config
   ```

### Grafana

1. **Acceder a la interfaz web:**
   ```
   http://158.23.84.89/grafana/
   ```
   Login: `admin` / `admin`

2. **Verificar datasource:**
   - Ir a Configuration > Data Sources
   - Debería existir "Prometheus" configurado

3. **Verificar dashboards:**
   - Ir a Dashboards
   - Deberían estar los dashboards pre-configurados

### Elasticsearch

1. **Verificar cluster health:**
   ```bash
   curl http://158.23.84.89/elasticsearch/_cluster/health?pretty
   ```
   Status debería ser `green` o `yellow` (no `red`)

2. **Verificar índices:**
   ```bash
   curl http://158.23.84.89/elasticsearch/_cat/indices?v
   ```

3. **Verificar que Filebeat está enviando logs:**
   ```bash
   curl http://158.23.84.89/elasticsearch/filebeat-*/_search?pretty
   ```

### Locust

1. **Acceder a la interfaz web:**
   ```
   http://158.23.84.89:8089/
   ```

2. **Verificar que master y worker están conectados:**
   - En la interfaz web, debería mostrar "1 worker connected"

## Solución de Problemas Comunes

### Servicio no está corriendo

```bash
# Ver estado
docker compose ps

# Ver logs del servicio
docker compose logs [nombre-servicio]

# Reiniciar servicio
docker compose restart [nombre-servicio]

# Reiniciar todos los servicios
docker compose restart
```

### Servicio no responde HTTP

1. **Verificar que el contenedor está corriendo:**
   ```bash
   docker ps | grep [nombre-servicio]
   ```

2. **Verificar logs:**
   ```bash
   docker compose logs [nombre-servicio] | tail -50
   ```

3. **Verificar puertos:**
   ```bash
   docker compose ps
   # Verificar que los puertos están mapeados correctamente
   ```

4. **Verificar Nginx:**
   ```bash
   docker compose logs nginx | tail -50
   ```

### Problemas de memoria

```bash
# Ver uso de memoria
free -h
docker stats --no-stream

# Si está alto, considerar:
# 1. Aumentar tamaño de VM
# 2. Reducir recursos de contenedores
# 3. Ajustar configuración de Elasticsearch (ES_JAVA_OPTS)
```

### Problemas de disco

```bash
# Ver uso de disco
df -h
docker system df

# Limpiar espacio si es necesario
docker system prune -a  # CUIDADO: elimina imágenes no usadas
docker volume prune     # CUIDADO: elimina volúmenes no usados
```

### Reiniciar todo el stack

```bash
# Conectarse a la VM
ssh adminuser@158.23.84.89
cd ~

# Detener todo
docker compose down

# Levantar todo
docker compose up -d

# Ver estado
docker compose ps
```

## Checklist de Verificación Completa

- [ ] Todos los contenedores están corriendo (`docker compose ps`)
- [ ] SonarQube responde en http://158.23.84.89/sonar/
- [ ] Prometheus responde en http://158.23.84.89/prometheus/
- [ ] Grafana responde en http://158.23.84.89/grafana/
- [ ] Alertmanager responde en http://158.23.84.89/alertmanager/
- [ ] Elasticsearch responde en http://158.23.84.89/elasticsearch/
- [ ] Locust responde en http://158.23.84.89:8089/
- [ ] Nginx redirige correctamente desde http://158.23.84.89/
- [ ] No hay errores en los logs (`docker compose logs`)
- [ ] Uso de memoria < 90%
- [ ] Uso de disco < 90%
- [ ] Prometheus puede scrapear targets
- [ ] Grafana puede conectarse a Prometheus
- [ ] Elasticsearch tiene índices de Filebeat

## Comandos Útiles de Diagnóstico

```bash
# Ver todos los logs recientes
docker compose logs --tail=100

# Ver logs de errores solamente
docker compose logs | grep -i error

# Ver uso de recursos en tiempo real
docker stats

# Ver red de contenedores
docker network ls
docker network inspect [nombre-red]

# Ver volúmenes
docker volume ls
docker volume inspect [nombre-volumen]

# Reiniciar un servicio específico
docker compose restart [nombre-servicio]

# Ver configuración de docker compose
docker compose config
```

## URLs de Acceso Rápido

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| SonarQube | http://158.23.84.89/sonar/ | admin/admin |
| Prometheus | http://158.23.84.89/prometheus/ | - |
| Grafana | http://158.23.84.89/grafana/ | admin/admin |
| Alertmanager | http://158.23.84.89/alertmanager/ | - |
| Elasticsearch | http://158.23.84.89/elasticsearch/ | - |
| Locust | http://158.23.84.89:8089/ | - |
| Nginx (raíz) | http://158.23.84.89/ | Redirige a SonarQube |

**Nota:** Reemplaza `158.23.84.89` con la IP real de tu VM.


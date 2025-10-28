# Kubernetes local con k3s (Docker Compose)

Este documento describe cómo levantar el clúster k3s dentro de Docker y desplegar los microservicios del proyecto en local, preservando los endpoints originales. Las instrucciones están pensadas para Windows usando cmd.exe.

## Visión general
- Se levanta un clúster k3s en un contenedor Docker (servicio `k3s` definido en `Ansible/docker-compose.yml`).
- Se publican NodePorts hacia puertos del host para acceder a los servicios desde `localhost`.
- Los manifiestos de Kubernetes están en la carpeta `k8s/` (en el raíz del repo) y se aplican en el namespace `ecommerce` mediante Kustomize.
- Eureka (service discovery) se usa dentro del clúster; los servicios se registran con la IP del Pod.

## Requisitos
- Docker Desktop instalado y corriendo.
- Puertos disponibles en el host: 8080, 8300, 8400, 8500, 8600, 8700, 8800, 8900.
- Ubicarse en el repositorio clonado: `C:\Users\<tu-usuario>\Downloads\ti2 para calificar\ecommerce-microservice-backend-app`.

## Puertos expuestos (NodePorts → Host)
- API Gateway: NodePort 30080 → Host 8080
- order-service: 30300 → 8300
- payment-service: 30400 → 8400
- product-service: 30500 → 8500
- shipping-service: 30600 → 8600
- user-service: 30700 → 8700
- favourite-service: 30800 → 8800
- proxy-client: 30900 → 8900

Estos mapeos están definidos en `Ansible/docker-compose.yml` (sección ports del servicio `k3s`).

## Paso a paso (cmd.exe)

1) Bajar y limpiar (si hubiera restos previos)
```bat
cd /d "C:\Users\aguir\Downloads\ti2 para calificar\ecommerce-microservice-backend-app\Ansible"
docker compose --profile k8s down -v
REM Borrar el volumen de datos del clúster (opcional, para reset total)
docker volume rm k3s-data 2>nul
```

2) Levantar k3s
```bat
docker compose --profile k8s up -d k3s
docker logs --tail 50 k3s
```

3) Copiar los manifiestos de k8s al contenedor `k3s`
(Ejecutar desde la raíz del repo)
```bat
cd /d "C:\Users\aguir\Downloads\ti2 para calificar\ecommerce-microservice-backend-app"
docker cp ".\k8s" k3s:/output/k8s
```

4) Aplicar todos los manifiestos (Kustomize) y esperar
```bat
docker exec -it k3s sh -c "kubectl apply -k /output/k8s"
docker exec -it k3s sh -c "kubectl -n ecommerce get pods -o wide"
docker exec -it k3s sh -c "kubectl wait --for=condition=available --timeout=180s deployment --all -n ecommerce"
```

5) Verificar Services y NodePorts
```bat
docker exec -it k3s sh -c "kubectl -n ecommerce get svc -o wide"
```
Deberías ver, por ejemplo, `api-gateway` con `8080:30080/TCP` y los demás servicios con los puertos indicados arriba.

## Pruebas rápidas

- Salud del API Gateway
```bat
curl http://localhost:8080/actuator/health
```

- Endpoints directos de cada servicio (NodePorts)
```bat
curl -v http://localhost:8500/product-service/api/products
curl -v http://localhost:8700/user-service/api/users
curl -v http://localhost:8600/shipping-service/api/shippings
curl -v http://localhost:8400/payment-service/api/payments
curl -v http://localhost:8300/order-service/api/orders
curl -v http://localhost:8800/favourite-service/api/favourites
```

- Vía API Gateway (rutas preservadas)
```bat
curl -v http://localhost:8080/app/api/products
curl -v http://localhost:8080/product-service/api/products
curl -v http://localhost:8080/user-service/api/users
curl -v http://localhost:8080/shipping-service/api/shippings
curl -v http://localhost:8080/payment-service/api/payments
curl -v http://localhost:8080/order-service/api/orders
curl -v http://localhost:8080/favourite-service/api/favourites
```

Nota: Si obtienes 404 o 503 de inmediato, espera 20–60 segundos a que todos los microservicios terminen de registrarse en Eureka y reintenta.

## Eureka y diagnóstico dentro del clúster

- Ver aplicaciones registradas en Eureka (desde dentro del cluster):
```bat
docker exec -it k3s sh -c "kubectl run eureka-check --rm -it --image=curlimages/curl:8.10.1 --restart=Never -- curl -s http://service-discovery:8761/eureka/apps | head -n 80"
```

- Logs de despliegues (ejemplos):
```bat
docker exec -it k3s sh -c "kubectl -n ecommerce logs --tail=200 deploy/service-discovery"
docker exec -it k3s sh -c "kubectl -n ecommerce logs --tail=200 deploy/api-gateway"
docker exec -it k3s sh -c "kubectl -n ecommerce logs --tail=200 deploy/product-service"
docker exec -it k3s sh -c "kubectl -n ecommerce logs --tail=200 deploy/user-service"
docker exec -it k3s sh -c "kubectl -n ecommerce logs --tail=200 deploy/shipping-service"
docker exec -it k3s sh -c "kubectl -n ecommerce logs --tail=200 deploy/payment-service"
docker exec -it k3s sh -c "kubectl -n ecommerce logs --tail=200 deploy/order-service"
docker exec -it k3s sh -c "kubectl -n ecommerce logs --tail=200 deploy/favourite-service"
```

## Solución de problemas comunes

- 404/503 en API Gateway justo después de desplegar:
  - Espera 20–60s a que los servicios se registren en Eureka.
  - Verifica el estado del gateway: `curl http://localhost:8080/actuator/health`.
  - Comprueba Eureka: comando de `eureka-check` más arriba.

- Un servicio responde 400/500 "No instances available":
  - Revisa su log correspondiente.
  - Confirma que el Pod esté `Running` y con `1/1` en `kubectl get pods -n ecommerce`.

- Conflicto de puertos al levantar k3s:
  - Asegúrate de que los puertos 8080, 8300, 8400, 8500, 8600, 8700, 8800, 8900 estén libres en el host.

- ¿Por qué no veo la UI de Eureka desde el host?
  - El servicio de Eureka está expuesto como `ClusterIP` (sólo dentro del clúster). Puedes consultar su API vía `kubectl run ... curl` (ver "Eureka y diagnóstico"). Si deseas exponerlo al host, puedes cambiarlo a `NodePort` en `k8s/service-discovery.yaml`.

## Apagar el entorno y limpiar
```bat
cd /d "C:\Users\aguir\Downloads\ti2 para calificar\ecommerce-microservice-backend-app\Ansible"
docker compose --profile k8s down
REM Limpieza total opcional (borra el estado del clúster)
docker compose --profile k8s down -v
docker volume rm k3s-data 2>nul
```

## kubeconfig (opcional)
El kubeconfig del clúster k3s se escribe dentro del contenedor en `/output/kubeconfig.yaml` y está montado en el host como `Ansible/k3s/kubeconfig.yaml`. Si tienes `kubectl` instalado en el host, puedes usar:
```bat
set KUBECONFIG=%CD%\Ansible\k3s\kubeconfig.yaml
kubectl get nodes
kubectl get pods -n ecommerce
```


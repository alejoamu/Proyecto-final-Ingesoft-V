# Plan de Rollback

## Objetivo
Definir procedimientos rápidos y seguros para revertir despliegues problemáticos minimizando impacto.

## Triggers de Rollback
- Degradación de métricas críticas (latencia > umbral, errores 5xx > X%).
- Fallo funcional grave (endpoint principal no responde).
- Descubrimiento de vulnerabilidad crítica post-deploy.
- Incumplimiento del SLA en primeros N minutos.

## Estrategias
1. **Reversión de Tag/Imagen**:
   - Mantener siempre la imagen anterior etiquetada: `service:previous`.
   - Despliegue: `kubectl set image deployment/<svc> <container>=<registry>/<svc>:previous`.
2. **Git Revert**:
   - `git revert <commit_del_release>` → fuerza nueva ejecución de CI con versión correctiva (hotfix).
3. **Rollback de Base de Datos**:
   - Migraciones Flyway: versionar scripts reversibles. Si migración irreversible, aplicar script de compensación.
   - Backup automático antes de deploy (snapshot). Restaurar snapshot si la migración rompe integridad.
4. **Config Server**:
   - Mantener copia de configs previas (`config-rollback-<fecha>.yml`).
   - Reaplicar y refrescar: `curl -X POST http://cloud-config/actuator/refresh`.
5. **Feature Flags**:
   - Para cambios grandes, envolver en bandera. Rollback lógico: desactivar flag sin revertir código.

## Procedimiento Paso a Paso
1. Detectar incidente y clasificar severidad.
2. Notificar en Slack canal `#incidentes` con: versión, servicios afectados, métrica.
3. Seleccionar estrategia:
   - Solo imagen nueva falla → reversión de imagen.
   - Código introdujo bug crítico → git revert + redeploy.
   - Migración DB rota → restaurar backup + revertir imagen.
4. Ejecutar rollback.
5. Validar estado (smoke tests + health endpoints).
6. Registrar en Issue original con etiqueta `rollback-required` y comentario final.
7. Crear post-mortem si severidad alta (documentar causa raíz, mejoras preventivas).

## Comandos Útiles
```bash
# Ver versión desplegada (anotada en label)
kubectl get deploy <svc> -o jsonpath='{.metadata.labels.version}'

# Rollback imagen
docker pull <registry>/<svc>:previous
kubectl set image deployment/<svc> <svc>=<registry>/<svc>:previous --record

# Revert commit
git revert <hash>
git push origin main

# Restaurar migraciones (ejemplo)
# Aplicar script down si existe
psql -f V20250221__down.sql
```

## Validación Post-Rollback
- Health actuators: HTTP 200.
- Métricas APM: latencia vuelve a baseline.
- Errores 5xx reducidos < umbral.

## Métricas a Monitorear Durante Rollback
- Tiempo total de ejecución del rollback.
- Tiempo de detección (TTD) + Tiempo de recuperación (TTR).
- Incidentes por tipo de estrategia aplicativo vs infra.

## Prevención
- Canary deployments (porcentaje de tráfico controlado antes de rollout completo).
- Tests automáticos de migraciones en entorno staging con snapshot real.
- Monitoring y alertado más granular (Resilience4j metrics, Prometheus alert rules).

## Checklist Rápido
- [ ] Identificado el motivo.
- [ ] Elegida estrategia.
- [ ] Ejecutado rollback.
- [ ] Verificado estado.
- [ ] Documentado en Issue.
- [ ] Post-mortem (si aplica).


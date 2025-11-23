# Proceso Formal de Change Management

## Objetivos
Gestionar cambios de manera controlada garantizando trazabilidad, evaluación de impacto, aprobación y rollback seguro.

## Roles
- Product Owner: prioriza cambios.
- Tech Lead: evalúa impacto técnico y riesgos.
- QA / Tester: valida criterios de aceptación y pruebas.
- Release Manager: autoriza despliegue a producción.

## Flujo de Cambio
1. Registro (Change Request):
   - Crear Issue con etiqueta `change-request` describiendo: motivo, alcance, impacto esperado.
2. Clasificación:
   - Tipo: Funcional, Técnica, Seguridad, Hotfix.
   - Criticidad: Baja, Media, Alta.
3. Evaluación:
   - Tech Lead agrega análisis: componentes afectados, migraciones, riesgos, esfuerzo (story points o horas), dependencias externas.
4. Aprobación:
   - Product Owner y Release Manager revisan y etiquetan `approved-for-dev`.
5. Implementación (Dev):
   - Branch convención: `feature/<cambio>` o `fix/<cambio>`.
   - Commits con Conventional Commits (ej. `feat: ...`, `fix: ...`).
6. QA / Validación:
   - Ejecutar pruebas unitarias, integración, e2e, performance si aplica.
   - Si pasa, etiquetar Issue con `ready-for-stage`.
7. Stage / Pre-Producción:
   - Despliegue vía workflow `deploy-gated.yml` a stage.
   - Ejecutar smoke + pruebas funcionales focalizadas.
   - Etiquetar Issue `ready-for-prod`.
8. Producción:
   - Aprobación manual (environment protegido) antes de job de producción.
   - Despliegue automático; registrar versión y actualizar CHANGELOG.
9. Post-Implementation Review:
   - Verificar métricas (errores, logs, rendimiento) en las primeras horas.
   - Marcar Issue `closed` si todo OK.

## Criterios de Aprobación
- Código revisado (PR con al menos 1 reviewer técnico).
- Cobertura >= objetivo (ej. 60%).
- 0 vulnerabilidades HIGH/CRITICAL nuevas.
- Quality Gate en Sonar: Passed.
- Pruebas E2E clave: Passed.

## Documentación asociada
- Impacto: en Issue inicial.
- Diseño técnico: adjuntar diagrama/archivo en `Docs/` si es cambio mayor.
- Rollback plan: referencia a `Docs/ROLLBACK_PLAN.md`.

## Herramientas Soportadas
- GitHub Issues & Projects para backlog.
- GitHub Actions (workflows: semantic-release, deploy-gated, integrated pipeline).
- SonarQube para calidad.
- Trivy para seguridad.

## Métricas
- Lead Time del cambio: tiempo desde `change-request` abierto a Release.
- Número de cambios urgentes (hotfix) por sprint.
- Ratio de cambios revertidos.
- Tiempo medio de rollback.

## Etiquetas Estándar
`change-request`, `approved-for-dev`, `ready-for-stage`, `ready-for-prod`, `hotfix`, `security`, `rollback-required`, `release`, `draft`.

## Escalamiento
- Si el cambio implica riesgo alto (seguridad crítica, impacto financiero), se requiere reunión formal y firma (comentario `@release-manager` y `@product-owner`).

## Automatización Integrada
- Versionado semántico: genera tag y release automáticamente según commits.
- Draft release notes: workflow `release-draft.yml`.
- Notificaciones: `notifications.yml` alerta fallos + snippet de errores.

## Revisión Periódica
- Trimestral: revisar proceso, ajustar métricas y umbrales (cobertura, vulnerabilidades). 


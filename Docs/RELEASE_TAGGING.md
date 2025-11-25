# Sistema de Etiquetado de Releases

## Convención de Tags
- Formato estándar: `v<major>.<minor>.<patch>` (ej: `v1.4.2`).
- Pre-releases:
  - Beta (develop): `v1.5.0-beta.<incremento>`.
  - Release Candidate (stage): `v1.5.0-rc.<incremento>`.

## Generación Automática
- semantic-release crea tags según tipo de commit:
  - `feat:` → incrementa minor.
  - `fix:` → incrementa patch.
  - `feat!` o `BREAKING CHANGE:` → incrementa major.
  - Otros (docs, chore, refactor) no incrementan versión salvo breaking.

## Pasos para un Release Estándar
1. Merge de PRs a `develop` con commits convencionales.
2. Pipeline semantic-release en `develop` genera pre-release `beta` (opcional para pruebas tempranas).
3. Merge a `stage` → genera `rc` y se despliega a stage (aprobaciones manuales).
4. Merge a `main` → genera release final `vX.Y.Z` + GitHub Release + actualización de `CHANGELOG.md`.

## Draft Manual de Release Notes
- Ejecutar workflow `Generate Release Notes Draft` (`release-draft.yml`), revisa Issue creado.
- Ajustar texto si se necesita (agregar secciones: Highlights, Breaking Changes, Upgrade Notes).

## Estructura Recomendada de Release Notes
```
## vX.Y.Z - YYYY-MM-DD
### Highlights
- Nueva funcionalidad ...
### Fixes
- Corregido bug ...
### Performance
- Optimizado ...
### Security
- Actualizado dependencia ...
### Breaking Changes
- Cambio en contrato API / endpoint removido
### Upgrade Notes
- Ejecutar migración DB V2025_03__add_column.sql antes de iniciar servicio
```

## Etiquetas en Issues/PR
- `release` : PR que prepara cambios finales.
- `breaking-change` : marcar cuando hay cambios incompatibles.
- `needs-docs` : requiere actualización de documentación.

## Rollback de Tag
- Si un release es retirado: crear tag `vX.Y.Z-yanked` o usar GitHub Release "Mark as pre-release" + Issue de rollback.
- Revert commits del release y ejecutar nueva versión patch/hotfix.

## Verificación Post-Release
- Confirmar tag creado: `git fetch --tags && git tag -l | grep vX.Y.Z`.
- Revisar Release en GitHub (assets, notas). 
- Validar CHANGELOG actualizado (última sección corresponde a la versión nueva).

## Integración con CI de Docker
- Tags semver aplicados a imágenes: `ghcr.io/<org>/ecommerce/<service>:vX.Y.Z` y alias mayor-menor `vX.Y`.
- Último release también puede etiquetarse como `latest` (agregar en metadata-action si se requiere).

## Buenas Prácticas
- No fusionar commits sin convención (evita versión incorrecta o salto inesperado).
- Revisión de PR: validar que no haya breaking ocultos sin anotación.
- Documentar Breaking Changes en los commit messages o en la descripción del PR.

## Tooling Complementario
- commitlint (pendiente) para validar mensajes.
- Release please (alternativa) si se decide migrar de semantic-release.



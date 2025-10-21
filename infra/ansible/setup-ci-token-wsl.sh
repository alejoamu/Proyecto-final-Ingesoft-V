#!/usr/bin/env bash
set -euo pipefail

# Ejecutar desde infra/ansible (este script está en esta carpeta)
cd "$(dirname "$0")"

if [ ! -f .env ]; then
  echo "[ERROR] No se encontró .env. Copia .env.example a .env y define GH_TOKEN."
  exit 1
fi

# Cargar variables desde .env
set -a
source .env
set +a

if [ -z "${GH_TOKEN:-}" ]; then
  echo "[ERROR] GH_TOKEN no está definido en .env"
  exit 1
fi

# Ejecutar solo el stack CI en la VM CI, inyectando la credencial de GitHub vía JCasC
ansible-playbook -i inventory.ini site.yml \
  --limit ci_vm \
  -e jenkins_create_github_token_credential=true \
  -e jenkins_github_token="${GH_TOKEN}" \
  -e repo_src=../..

echo "[OK] Jenkins desplegado/actualizado con credencial GH (ID por defecto: 'github-token'). Configura CREDENTIALS_ID en el seed-job para SCM con push."

# Guía de Ejecución en WSL (Windows Subsystem for Linux)

Esta guía te ayudará a configurar y ejecutar el playbook de Ansible desde WSL.

## Prerrequisitos

### 1. Verificar WSL instalado

```bash
# Verificar versión de WSL
wsl --version

# Si no está instalado, instálalo desde PowerShell (como administrador):
# wsl --install
```

### 2. Actualizar sistema (Ubuntu/Debian)

```bash
sudo apt update && sudo apt upgrade -y
```

## Instalación de Dependencias

### 1. Instalar Python y pip

```bash
sudo apt install -y python3 python3-pip python3-venv
python3 --version  # Debe ser 3.8 o superior
```

### 2. Instalar Ansible

**Opción A: Desde pip (recomendado)**
```bash
pip3 install --user ansible
# O instalar globalmente:
sudo pip3 install ansible

# Verificar instalación
ansible --version
```

**Opción B: Desde apt (puede estar desactualizado)**
```bash
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

### 3. Instalar Azure CLI

```bash
# Instalar Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verificar instalación
az --version

# Login en Azure
az login
```

### 4. Instalar kubectl

```bash
# Descargar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Instalar
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verificar
kubectl version --client
```

### 5. Instalar Helm

```bash
# Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verificar
helm version
```

### 6. Instalar herramientas adicionales (opcional pero recomendado)

```bash
sudo apt install -y curl wget git sshpass
```

## Configuración del Proyecto

### 1. Navegar al directorio del proyecto

```bash
# Desde WSL, navega a tu proyecto
cd /mnt/c/Users/aguir/Downloads/ti2\ para\ calificar/Proyecto-final-Ingesoft-V/Ansible

# O si está en otra ubicación:
# cd /ruta/a/tu/proyecto/Ansible
```

### 2. Verificar inventario

Edita `inventory.ini` si es necesario:

```bash
cat inventory.ini
```

Debería verse algo así:
```ini
[ci]
158.23.84.89 ansible_user=adminuser ansible_ssh_pass=Password@1

[local]
localhost ansible_connection=local
```

### 3. Configurar SSH (si es necesario)

Si necesitas conectarte a la VM por SSH:

```bash
# Generar clave SSH (si no tienes)
ssh-keygen -t rsa -b 4096

# Copiar clave a la VM (opcional, si usas autenticación por clave)
ssh-copy-id adminuser@158.23.84.89
```

### 4. Verificar conectividad

```bash
# Probar conexión a la VM
ping -c 3 158.23.84.89

# Probar SSH (si es necesario)
ssh adminuser@158.23.84.89
```

## Ejecución del Playbook

### Ejecución básica (solo VM de CI)

```bash
# Desde el directorio Ansible
cd Ansible

# Ejecutar solo el play de CI (sin AKS)
ansible-playbook -i inventory.ini playbook.yml --limit ci
```

### Ejecución completa (VM de CI + AKS)

```bash
# Configurar variables de entorno para AKS
export AKS_RESOURCE_GROUP="tu-resource-group"
export AKS_CLUSTER_NAME="tu-cluster-name"

# Ejecutar playbook completo
ansible-playbook -i inventory.ini playbook.yml
```

### Ejecución con opciones adicionales

```bash
# Ejecutar con verbose para ver más detalles
ansible-playbook -i inventory.ini playbook.yml -v

# Ejecutar solo tareas específicas (tags)
ansible-playbook -i inventory.ini playbook.yml --tags "docker,nginx"

# Ejecutar con check mode (dry-run)
ansible-playbook -i inventory.ini playbook.yml --check

# Ejecutar solo para localhost (AKS)
ansible-playbook -i inventory.ini playbook.yml --limit local
```

## Solución de Problemas Comunes en WSL

### 1. Problema: "Permission denied" al ejecutar comandos

```bash
# Asegúrate de tener permisos de ejecución
chmod +x /usr/local/bin/kubectl
chmod +x /usr/local/bin/helm

# Verificar PATH
echo $PATH
```

### 2. Problema: Ansible no encuentra Python

```bash
# Verificar Python
which python3
python3 --version

# Si es necesario, crear symlink
sudo ln -s /usr/bin/python3 /usr/bin/python
```

### 3. Problema: Azure CLI no funciona en WSL

```bash
# A veces Azure CLI necesita configuración adicional
az login --use-device-code

# O usar browser
az login
```

### 4. Problema: Problemas con line endings (CRLF vs LF)

```bash
# Convertir line endings si es necesario
sudo apt install -y dos2unix
find . -type f -name "*.sh" -exec dos2unix {} \;
find . -type f -name "*.yml" -exec dos2unix {} \;
```

### 5. Problema: Docker no funciona desde WSL

Si necesitas Docker en WSL (para desarrollo local):

```bash
# Instalar Docker Desktop para Windows y habilitar integración WSL
# O instalar Docker directamente en WSL:
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 6. Problema: Rutas de Windows vs Linux

```bash
# En WSL, las rutas de Windows están en /mnt/c/
# Ejemplo:
cd /mnt/c/Users/aguir/Downloads/ti2\ para\ calificar/Proyecto-final-Ingesoft-V

# O mejor, clona el proyecto dentro de WSL:
cd ~
git clone <tu-repo>
```

## Script de Ejecución Rápida

Crea un script `run-playbook.sh`:

```bash
#!/bin/bash

# Script para ejecutar el playbook desde WSL

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Ejecutando Playbook de Ansible ===${NC}"

# Verificar que estamos en el directorio correcto
if [ ! -f "playbook.yml" ]; then
    echo "Error: playbook.yml no encontrado. ¿Estás en el directorio Ansible?"
    exit 1
fi

# Verificar variables de AKS
if [ -z "$AKS_RESOURCE_GROUP" ] || [ -z "$AKS_CLUSTER_NAME" ]; then
    echo -e "${YELLOW}Advertencia: Variables de AKS no configuradas${NC}"
    echo "Ejecutando solo playbook de CI..."
    ansible-playbook -i inventory.ini playbook.yml --limit ci
else
    echo -e "${GREEN}Variables de AKS configuradas:${NC}"
    echo "  AKS_RESOURCE_GROUP: $AKS_RESOURCE_GROUP"
    echo "  AKS_CLUSTER_NAME: $AKS_CLUSTER_NAME"
    echo ""
    ansible-playbook -i inventory.ini playbook.yml
fi

echo -e "${GREEN}=== Playbook completado ===${NC}"
```

Hazlo ejecutable:

```bash
chmod +x run-playbook.sh
./run-playbook.sh
```

## Verificación Post-Ejecución

### Verificar servicios en la VM

```bash
# Conectarse a la VM
ssh adminuser@158.23.84.89

# Verificar contenedores Docker
docker ps

# Verificar servicios
docker compose ps

# Ver logs
docker compose logs -f
```

### Verificar acceso a herramientas

Desde tu navegador en Windows, accede a:
- SonarQube: `http://158.23.84.89/sonar/`
- Prometheus: `http://158.23.84.89/prometheus/`
- Grafana: `http://158.23.84.89/grafana/`
- Alertmanager: `http://158.23.84.89/alertmanager/`
- Elasticsearch: `http://158.23.84.89/elasticsearch/`
- Locust: `http://158.23.84.89:8089/`

## Comandos Útiles

```bash
# Verificar versión de Ansible
ansible --version

# Verificar hosts en inventario
ansible-inventory -i inventory.ini --list

# Probar conexión a hosts
ansible all -i inventory.ini -m ping

# Verificar configuración de Ansible
ansible-config dump

# Ejecutar comando ad-hoc en la VM
ansible ci -i inventory.ini -m shell -a "docker ps"
```

## Notas Importantes

1. **Rutas de archivos**: En WSL, usa rutas de Linux (`/mnt/c/...` para acceder a Windows)
2. **Permisos**: Algunos comandos pueden requerir `sudo`
3. **Azure CLI**: Asegúrate de estar logueado (`az login`)
4. **SSH**: Si usas autenticación por clave, configura SSH correctamente
5. **Firewall**: Asegúrate de que los puertos necesarios estén abiertos en la VM

## Recursos Adicionales

- [Documentación de Ansible](https://docs.ansible.com/)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)


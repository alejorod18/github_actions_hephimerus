# GitHub Actions Hephimerus

Este repositorio contiene la infraestructura necesaria para automatizar el despliegue de aplicaciones Docker en AWS utilizando Terraform, GitHub Actions, y otros servicios de AWS como EC2, ECR, y VPC. El propósito principal es generar una instancia EC2 temporal que construye una imagen Docker y la sube a ECR, para luego eliminar la instancia.

## Contenido

- [Descripción](#descripción)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Uso](#uso)
- [Requisitos](#requisitos)
- [Configuración](#configuración)
- [Personalización](#personalización)
- [Contribuciones](#contribuciones)
- [Licencia](#licencia)

## Descripción

El proyecto automatiza el flujo de trabajo CI/CD para construir y desplegar aplicaciones Docker en AWS. Utiliza una instancia EC2 temporal para construir la imagen Docker y luego la sube a un repositorio ECR. Una vez que el proceso de construcción y despliegue ha terminado, la instancia EC2 es eliminada.

## Estructura del repositorio

- `.github/workflows/`: Contiene los flujos de trabajo de GitHub Actions.
- `Dockerfile`: Definición de la imagen Docker a construir.
- `ec2.tf`: Configuración de instancias EC2 para despliegue.
- `ecr.tf`: Configuración del repositorio ECR para almacenar imágenes Docker.
- `network.tf`: Configuración de red, incluyendo VPC y subredes.
- `provider.tf`: Configuración del proveedor de AWS.
- `tls_key.tf`: Gestión de claves TLS para acceso a instancias.
- `variables.tf`: Definición de variables de Terraform.

## Uso

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/alejorod18/github_actions_hephimerus.git
   cd github_actions_hephimerus
   ```

2. **Configurar GitHub Secrets**:
   Configura los siguientes secretos en GitHub para permitir el despliegue:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `TF_VAR_GITHUB_REPOSITORY`
   - `TF_VAR_GITHUB_TOKEN`
   - `TF_VAR_GITHUB_USER`
   - `TF_VAR_GITHUB_WORKSPACE`

3. **Ejecutar los workflows de GitHub Actions**:
   - Los workflows se ejecutan automáticamente en función de los eventos configurados (push, pull request, etc.).

4. **Aplicar la infraestructura de Terraform**:
   ```bash
   terraform init
   terraform apply
   ```

## Requisitos

- Cuenta de AWS con permisos para EC2, ECR, y VPC.
- Terraform instalado en tu máquina local.
- GitHub Secrets configurados para autenticarte en AWS.

## Configuración

1. **Variables**: Edita `variables.tf` para configurar los detalles específicos del entorno, como el tipo de instancia, la región, etc.
2. **Terraform**: Ejecuta los comandos de Terraform para desplegar la infraestructura.

## Personalización

- **Modificar el comportamiento del despliegue**: Para personalizar el comportamiento de la instancia EC2 (como los comandos ejecutados durante el build), edita el bloque `inline` en el archivo `ec2.tf`.
  
- **Actualizar la AMI**: Asegúrate de usar la AMI correcta para tu región, reemplazando el valor en `ec2.tf`. Se asume que se utilizará Amazon Linux.

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o un pull request para discutir cualquier cambio.

## Licencia

Este proyecto está bajo la Licencia Apache 2.0. Consulta el archivo [LICENSE](LICENSE) para más detalles.


# SINTRATEL Docket - Infrastructure as Code

Este repositorio contiene la infraestructura del proyecto **SINTRATEL Docket**, administrada mediante Terraform y desplegada principalmente sobre AWS.

El objetivo es mantener la infraestructura versionada, reutilizable, parametrizada y automatizada, aplicando prácticas de DevOps como Infrastructure as Code, backend remoto, control de estado, GitHub Actions, OIDC, ECR y despliegue sobre Kubernetes.

---

## Arquitectura de infraestructura

El ambiente de desarrollo incluye:

- AWS VPC
- Subnets públicas y privadas
- NAT Gateway
- Amazon EKS
- Managed Node Group
- Amazon ECR
- Kubernetes Namespaces
- GitHub Actions
- GitHub OIDC
- IAM Roles
- Terraform Remote State en S3

Los módulos reutilizables se encuentran en el repositorio:

`Sintratel-Docket/terraform-modules`

Actualmente existen módulos para:

- Network
- EKS
- ECR

Los módulos son consumidos desde `docket-infra` utilizando versiones mediante tags de Git.

Ejemplo:

    source = "git::https://github.com/Sintratel-Docket/terraform-modules.git//ecr?ref=v0.4.0"

Esto permite mantener versiones estables de los módulos y evita depender directamente de cambios realizados en la rama principal del repositorio de módulos.

---

## Estructura del repositorio

    docket-infra/
    │
    ├── environments/
    │   │
    │   ├── dev/
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   ├── dev.tfvars
    │   │   ├── backend.tf
    │   │   ├── outputs.tf
    │   │   ├── iam_ecr_push.tf
    │   │   │
    │   │   └── kubernetes/
    │   │       ├── backend.tf
    │   │       ├── providers.tf
    │   │       ├── variables.tf
    │   │       ├── versions.tf
    │   │       └── namespaces.tf
    │   │
    │   ├── staging/
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   ├── outputs.tf
    │   │   ├── backend.tf
    │   │   └── staging.tfvars.example
    │   │
    │   └── prod/
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── outputs.tf
    │       ├── backend.tf
    │       └── prod.tfvars.example
    │
    ├── k8s/
    │   └── todos-api/
    │       ├── deployment.yaml
    │       └── service.yaml
    │
    └── .github/
        └── workflows/

Los ambientes `staging` y `prod` contienen únicamente el esqueleto base de infraestructura.

No se despliega infraestructura real en esos ambientes actualmente para evitar costos adicionales.

---

# Ambiente DEV

El ambiente principal actualmente desplegado es:

    Environment: dev
    AWS Region: us-east-1
    EKS Cluster: docket-dev
    Kubernetes Version: 1.35

La configuración se encuentra en:

    environments/dev

Los valores específicos del ambiente están almacenados en:

    dev.tfvars

De esta manera se evita colocar valores del ambiente directamente dentro de `main.tf`.

Esto permite mantener mayor modularidad, reutilización e idempotencia.

---

# Requisitos previos

Para trabajar con la infraestructura se necesita tener instalado:

- Terraform
- AWS CLI
- kubectl
- Git
- Acceso autorizado a la cuenta AWS del proyecto

Versión de Terraform utilizada durante el desarrollo:

    Terraform 1.14.6

Región AWS utilizada:

    us-east-1

AWS Account ID:

    429418377318

---

# Autenticación local con AWS

Para trabajar localmente no se utilizan perfiles permanentes de AWS.

Se utilizan credenciales temporales obtenidas mediante `aws login`.

En PowerShell:

    Remove-Item Env:AWS_ACCESS_KEY_ID -ErrorAction SilentlyContinue
    Remove-Item Env:AWS_SECRET_ACCESS_KEY -ErrorAction SilentlyContinue
    Remove-Item Env:AWS_SESSION_TOKEN -ErrorAction SilentlyContinue

    aws login

    aws configure export-credentials --format powershell | Invoke-Expression

Después se puede verificar la identidad actual con:

    aws sts get-caller-identity

La cuenta esperada es:

    429418377318

Si las credenciales temporales expiran durante una operación, se debe repetir el proceso de autenticación.

---

# Terraform Remote State

Terraform utiliza un backend remoto en Amazon S3.

Bucket:

    sintratel-docket-terraform-state-2026

El bucket cuenta con:

- S3 Versioning
- Encryption AES256
- Public Access Block
- State Locking

State principal de DEV:

    docket/dev/terraform.tfstate

State de Kubernetes:

    docket/dev/kubernetes.tfstate

El locking se encuentra configurado utilizando:

    use_lockfile = true

Esto ayuda a evitar que dos ejecuciones de Terraform modifiquen el mismo state al mismo tiempo.

---

# Inicializar Terraform

Entrar al ambiente DEV:

    cd .\environments\dev

Inicializar Terraform:

    terraform init -backend-config="bucket=sintratel-docket-terraform-state-2026"

Terraform descargará los providers, módulos necesarios y se conectará al backend remoto.

---

# Terraform Format

Para formatear los archivos Terraform:

    terraform fmt

Para validar que el formato sea correcto:

    terraform fmt -check

Este comando también es ejecutado automáticamente por GitHub Actions en los Pull Requests.

---

# Terraform Validate

Para validar sintaxis y configuración:

    terraform validate

El resultado esperado es similar a:

    Success! The configuration is valid.

---

# Terraform Plan

Antes de ejecutar cualquier cambio sobre la infraestructura se debe realizar un plan:

    terraform plan -var-file="dev.tfvars"

El plan debe ser revisado antes de realizar `apply`.

Es especialmente importante verificar que no aparezcan operaciones inesperadas como:

    destroy
    -/+
    must be replaced

sobre recursos importantes como:

- VPC
- Subnets
- NAT Gateway
- Amazon EKS
- Node Groups
- Amazon ECR
- IAM Roles

Cuando la infraestructura ya coincide completamente con la configuración, Terraform debe mostrar:

    No changes. Your infrastructure matches the configuration.

Este resultado también sirve como evidencia de idempotencia.

---

# Terraform Apply

Después de validar correctamente el plan:

    terraform apply -var-file="dev.tfvars"

Terraform mostrará nuevamente los cambios y solicitará confirmación antes de modificar infraestructura.

Cuando se desea garantizar que se aplique exactamente el plan revisado, se puede guardar primero:

    terraform plan -var-file="dev.tfvars" -out="tfplan"

Y luego aplicar:

    terraform apply "tfplan"

---

# Terraform Destroy

Para destruir un ambiente administrado por Terraform se puede utilizar:

    terraform destroy -var-file="dev.tfvars"

Este comando debe utilizarse con mucho cuidado.

En el ambiente DEV puede destruir recursos como:

- EKS
- Managed Node Groups
- VPC
- Subnets
- NAT Gateway
- ECR
- IAM
- otros recursos administrados por Terraform

Por esta razón, `terraform destroy` se encuentra documentado pero no se ejecuta como parte del flujo normal del proyecto.

Siempre se debe revisar primero el plan antes de destruir infraestructura.

---

# Manejo del State Lock

Si Terraform muestra un error indicando que el state se encuentra bloqueado, primero se debe comprobar que no exista otra ejecución activa.

En PowerShell:

    Get-Process terraform -ErrorAction SilentlyContinue

No se recomienda utilizar:

    -lock=false

como solución habitual.

Tampoco se debe ejecutar `terraform force-unlock` sin comprobar previamente que ningún proceso legítimo esté utilizando el state.

El state lock existe precisamente para evitar escrituras simultáneas sobre la infraestructura.

---

# Network

La infraestructura de red del ambiente DEV incluye una VPC:

    VPC ID: vpc-0a2a7c51af5f1ea1e
    CIDR: 10.10.0.0/16

Availability Zones:

    us-east-1a
    us-east-1b

Private Subnets:

    10.10.1.0/24
    10.10.2.0/24

Public Subnets:

    10.10.101.0/24
    10.10.102.0/24

También existe un NAT Gateway para permitir salida a Internet desde las subnets privadas.

---

# Amazon EKS

El clúster Kubernetes utilizado en desarrollo es:

    docket-dev

Versión:

    1.35

El cluster utiliza un Managed Node Group con:

    Instance type: t3.small
    Minimum nodes: 1
    Desired nodes: 1
    Maximum nodes: 2
    Capacity type: ON_DEMAND

Para configurar localmente el acceso de `kubectl`:

    aws eks update-kubeconfig `
      --region us-east-1 `
      --name docket-dev

Verificar acceso:

    kubectl get nodes

---

# Acceso administrativo a EKS

El acceso administrativo al clúster no depende dinámicamente de la identidad que ejecuta Terraform.

Se utilizan Access Entries explícitos para:

    JuanP
    GitHubActionsDocketInfra

Ambos tienen asociada:

    AmazonEKSClusterAdminPolicy

Esto permite mantener una configuración estable independientemente de si Terraform se ejecuta localmente o desde GitHub Actions.

---

# Kubernetes Namespaces

Terraform administra un namespace para cada componente de la aplicación.

Namespaces actuales:

    dev-frontend
    dev-auth-api
    dev-users-api
    dev-todos-api
    dev-log-message-processor

Para verificarlos:

    kubectl get namespaces

La definición Terraform de estos namespaces se encuentra en:

    environments/dev/kubernetes

El state de Kubernetes es independiente del state principal de infraestructura.

---

# Amazon ECR

El proyecto utiliza Amazon Elastic Container Registry para almacenar las imágenes Docker de los microservicios.

Repositorios:

    docket/frontend
    docket/auth-api
    docket/users-api
    docket/todos-api
    docket/log-message-processor

Todos están configurados con:

    Image Tag Mutability: IMMUTABLE
    Scan On Push: true
    Encryption: AES256

Las URLs son:

    429418377318.dkr.ecr.us-east-1.amazonaws.com/docket/frontend
    429418377318.dkr.ecr.us-east-1.amazonaws.com/docket/auth-api
    429418377318.dkr.ecr.us-east-1.amazonaws.com/docket/users-api
    429418377318.dkr.ecr.us-east-1.amazonaws.com/docket/todos-api
    429418377318.dkr.ecr.us-east-1.amazonaws.com/docket/log-message-processor

Para verificar los repositorios:

    aws ecr describe-repositories `
      --region us-east-1 `
      --query "repositories[*].[repositoryName,repositoryUri,imageTagMutability,imageScanningConfiguration.scanOnPush]" `
      --output table

---

# Versionado de imágenes

Los repositorios ECR utilizan tags inmutables.

Por esta razón, los pipelines deben publicar imágenes utilizando tags versionados y no deben depender del tag `latest`.

Ejemplos válidos:

    1.0.0
    1.0.1
    1.0.1-6b31a0f
    sha-6b31a0f

Ejemplo de imagen utilizada en DEV:

    429418377318.dkr.ecr.us-east-1.amazonaws.com/docket/todos-api:1.0.1-6b31a0f

Para consultar las imágenes almacenadas en `todos-api`:

    aws ecr describe-images `
      --repository-name docket/todos-api `
      --region us-east-1 `
      --query "imageDetails[*].[join(',', imageTags || ['<untagged>']), imagePushedAt]" `
      --output table

---

# GitHub Actions y OIDC

GitHub Actions se autentica contra AWS mediante OpenID Connect.

No se utilizan credenciales permanentes como:

    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY

Esto evita guardar credenciales AWS de larga duración dentro de GitHub Secrets.

---

# IAM Role de infraestructura

El pipeline de `docket-infra` utiliza:

    GitHubActionsDocketInfra

ARN:

    arn:aws:iam::429418377318:role/GitHubActionsDocketInfra

Este rol es utilizado únicamente para las operaciones relacionadas con Terraform e infraestructura.

---

# IAM Role para ECR Push

Los pipelines de los microservicios utilizan un rol independiente:

    GitHubActionsECRPush

ARN:

    arn:aws:iam::429418377318:role/GitHubActionsECRPush

Este rol utiliza GitHub OIDC.

El trust policy se encuentra restringido a los repositorios reales de los microservicios y a la rama:

    main

Repositorios permitidos:

    Sintratel-Docket/frontend
    Sintratel-Docket/auth-api
    Sintratel-Docket/users-api
    Sintratel-Docket/todos-api
    Sintratel-Docket/log-message-processor

El rol tiene permisos limitados principalmente a:

    ecr:GetAuthorizationToken
    ecr:BatchCheckLayerAvailability
    ecr:BatchGetImage
    ecr:DescribeImages
    ecr:InitiateLayerUpload
    ecr:UploadLayerPart
    ecr:CompleteLayerUpload
    ecr:PutImage

Los permisos sobre repositorios están limitados a los cinco ECR utilizados por SINTRATEL Docket.

No se utiliza `AdministratorAccess` para los pipelines de imágenes.

---

# Pipeline de infraestructura

El pipeline se encuentra dentro de:

    .github/workflows/

En cada Pull Request hacia `main` se ejecutan validaciones de Terraform.

Entre ellas:

    terraform fmt -check
    terraform validate
    terraform plan

También se valida la configuración Terraform relacionada con Kubernetes.

En los Pull Requests no se ejecuta automáticamente `apply`.

Esto permite revisar previamente todos los cambios de infraestructura.

---

# Terraform Apply desde GitHub Actions

Cuando un cambio es aprobado y mergeado hacia:

    main

el pipeline ejecuta `terraform apply` sobre el ambiente DEV.

El flujo general es:

    Feature Branch
          |
          v
    Pull Request
          |
          v
    fmt / validate / plan
          |
          v
    Review
          |
          v
    Merge to main
          |
          v
    terraform apply

---

# Deployment base de TODOs API

Como plantilla de despliegue Kubernetes para los demás microservicios se utilizó:

    todos-api

Namespace:

    dev-todos-api

Imagen utilizada:

    429418377318.dkr.ecr.us-east-1.amazonaws.com/docket/todos-api:1.0.1-6b31a0f

Los manifiestos Kubernetes se encuentran en:

    k8s/todos-api/deployment.yaml
    k8s/todos-api/service.yaml

---

# Deployment

Para aplicar el Deployment:

    kubectl apply -f .\k8s\todos-api\deployment.yaml

El Deployment crea una réplica del microservicio.

Para verificarlo:

    kubectl get deployment -n dev-todos-api

Resultado esperado:

    NAME        READY   UP-TO-DATE   AVAILABLE
    todos-api   1/1     1            1

---

# Service

Para aplicar el Service:

    kubectl apply -f .\k8s\todos-api\service.yaml

El Service utiliza:

    ClusterIP

y expone internamente:

    8082/TCP

Verificar:

    kubectl get service -n dev-todos-api

---

# Verificación del Pod

Para verificar el microservicio:

    kubectl get pods -n dev-todos-api

El resultado esperado es:

    READY   STATUS    RESTARTS
    1/1     Running   0

Con esto se cumple uno de los criterios principales de la Definition of Done de la HU.

---

# Diagnóstico de Kubernetes

Si un Pod no inicia correctamente:

    kubectl get pods -n dev-todos-api

Para consultar detalles:

    kubectl describe pod -n dev-todos-api <POD_NAME>

Para consultar logs:

    kubectl logs -n dev-todos-api <POD_NAME>

Algunos posibles estados de error son:

    ImagePullBackOff
    ErrImagePull
    CrashLoopBackOff
    CreateContainerError

No se deben realizar cambios sin revisar primero la información entregada por `describe` y `logs`.

---

# Staging

Se dejó creado el skeleton:

    environments/staging

Este ambiente utiliza la misma estructura parametrizada del ambiente DEV.

Archivo de configuración de ejemplo:

    staging.tfvars.example

Los valores específicos del ambiente se encuentran separados del código Terraform.

Actualmente no se ejecuta `terraform apply` sobre staging.

---

# Production

También se dejó creado el skeleton:

    environments/prod

Archivo de configuración de ejemplo:

    prod.tfvars.example

Los valores que requieren una configuración real antes de desplegar están marcados como:

    REPLACE_ME

Actualmente no existe infraestructura real de producción provisionada desde este skeleton.

Esto evita crear recursos AWS adicionales y generar costos innecesarios.

---

# Uso de variables

Los valores específicos de cada ambiente deben ser definidos utilizando variables y archivos `.tfvars`.

Ejemplo:

    environment  = "dev"
    cluster_name = "docket-dev"

El objetivo es evitar valores específicos del ambiente directamente dentro de `main.tf`.

Los `module source` son una excepción porque Terraform requiere que su valor sea estático.

Ejemplo:

    source = "git::https://github.com/Sintratel-Docket/terraform-modules.git//eks?ref=v0.3.1"

---

# Flujo de trabajo con Git

Los cambios de infraestructura deben realizarse utilizando ramas.

Ejemplo:

    git checkout main
    git pull origin main
    git checkout -b feat/nombre-cambio

Después de realizar los cambios:

    git status

Agregar:

    git add .

Crear commit:

    git commit -m "feat: description"

Subir rama:

    git push -u origin feat/nombre-cambio

Luego se crea un Pull Request hacia:

    main

El merge debe realizarse únicamente después de verificar que GitHub Actions termine correctamente.

---

# Responsabilidades del repositorio docket-infra

Este repositorio administra principalmente:

- Terraform
- AWS Infrastructure
- VPC
- EKS
- EKS Node Groups
- Kubernetes Namespaces
- Amazon ECR
- IAM Roles de infraestructura
- GitHub OIDC
- Manifiestos base de Kubernetes
- Skeletons de environments

---

# Responsabilidades de los repositorios de microservicios

Los pipelines propios de cada microservicio administran tareas como:

- Instalación de dependencias
- Lint
- Unit Tests
- Integration Tests
- Coverage
- Sonar
- Docker Build
- Semantic Versioning
- Push de imágenes hacia Amazon ECR

De esta manera existe una separación clara entre infraestructura y CI/CD de las aplicaciones.

---

# Microservicios del proyecto

SINTRATEL Docket utiliza los siguientes componentes:

    frontend
    auth-api
    users-api
    todos-api
    log-message-processor

Tecnologías principales:

    frontend                -> Vue.js
    auth-api                -> Go
    users-api               -> Java Spring Boot
    todos-api               -> Node.js
    log-message-processor   -> Python

También se utiliza Redis como broker o queue dentro de la arquitectura general del sistema.

---

# Verificaciones principales

Verificar AWS:

    aws sts get-caller-identity

Verificar cluster:

    kubectl get nodes

Verificar namespaces:

    kubectl get namespaces

Verificar Deployment:

    kubectl get deployment -n dev-todos-api

Verificar Service:

    kubectl get service -n dev-todos-api

Verificar Pod:

    kubectl get pods -n dev-todos-api

Verificar ECR:

    aws ecr describe-repositories `
      --region us-east-1 `
      --output table

Verificar infraestructura Terraform:

    cd .\environments\dev
    terraform plan -var-file="dev.tfvars"

---

# Definition of Done

Para esta HU se completaron los siguientes puntos:

- Backend remoto de Terraform en Amazon S3
- Versioning del bucket de state
- Encryption del backend
- State locking
- Infraestructura modular mediante Terraform
- Uso de módulos versionados
- Ambiente `environments/dev`
- Valores de ambiente parametrizados mediante variables
- Pipeline de GitHub Actions
- `terraform fmt -check` en Pull Requests
- `terraform validate` en Pull Requests
- `terraform plan` en Pull Requests
- `terraform apply` después del merge a `main`
- Amazon EKS provisionado mediante Terraform
- Managed Node Group funcionando
- Cinco namespaces Kubernetes creados
- Cinco repositorios Amazon ECR
- ECR con tags inmutables
- GitHub Actions autenticado contra AWS mediante OIDC
- IAM Role específico para push hacia ECR
- Deployment base de TODOs API
- Service Kubernetes tipo ClusterIP
- Imagen versionada almacenada en ECR
- Pod ejecutándose correctamente en DEV
- Skeleton de staging
- Skeleton de production
- Documentación de despliegue
- Documentación de destrucción controlada

---

# Evidencia principal de funcionamiento

El microservicio desplegado puede verificarse con:

    kubectl get pods -n dev-todos-api

Resultado esperado:

    READY   STATUS
    1/1     Running

La infraestructura puede comprobarse ejecutando:

    cd .\environments\dev
    terraform plan -var-file="dev.tfvars"

Cuando no existen cambios pendientes:

    No changes. Your infrastructure matches the configuration.

Esto permite comprobar que la infraestructura definida mediante Terraform coincide con la infraestructura real desplegada en AWS.

---

# Estado actual

El ambiente DEV se encuentra desplegado y funcional.

Actualmente están disponibles:

    VPC
    EKS
    Managed Node Group
    Kubernetes Namespaces
    Amazon ECR
    GitHub OIDC
    IAM Roles
    Terraform Remote State
    GitHub Actions
    TODOs API Deployment
    TODOs API Service
    TODOs API Pod Running

Los ambientes `staging` y `prod` permanecen únicamente como skeletons hasta que exista la necesidad de desplegarlos.

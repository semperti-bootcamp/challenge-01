# Desafíos de DevOps
## Challenge 01

### Consignas Generales
#### Como se publica el resultado del challenge solicitado: 
- Clonar este repositorio git en tu local
- Crear un nueva rama a partir del main branch
- Editar este README.md agregando los resultados a la tareas solicitadas
- Crear un nuevo repositorio en su Github personal y hacerlo público
- Pushear el local a este nuevo repo. Se debe mantener los commits originales.
- Armar un pull request de su repo publico a este repo original conciliando los cambios (resultados de las tareas)

#### Que se evalúa?

- Entendimiento de las consignas generales y las tareas particulares
- Formato MarkDown
- El paso a paso (a prueba de zonzos) sobre los pasos a ejecutar para resolver la tarea solicitada
- Investigar, googlear, proponer mejores mejoras
- Documentacion consultada y de soporte
- Problemas encontrados y como fueron resueltos
- Defensa del challenge al momento de revisar el PR.


> **Nota** : Las tareas a continuación se han clasificado según el nivel de experiencia; son solo recomendaciones y pueden ser diferentes según la propia experiencia del candidato.
> - Junior Engineer
> - Semi-Senior Engineer
> - Senior Engineer


## [DevOps Challenges](#devops-challenges)
  - [1. K8s deployment (Junior)](#1-k8s-deployment-junior)
  - [2. Linux Automation](#2-linux-automation)
  - [3. Docker Multi-Stage Build Exercise](#3-docker-multi-stage-build-exercise)


## 1. K8s deployment (Junior)

```bash
Scenario:

A company wants to roll out a web service built on Kubernetes. To make this happen, complete a file stub located at /home/ubuntu/tech-vault-q1/special-definition.yml with the steps that do the following:

- If you do not have your own K8s cluster, deploy a simple Kubernetes solution on your local machine. Document step by step. Examples: Minikube, Microk8s, Kind, K3, etc. 
- Creates a new namespace named "CyberCo".
- Deploys a new "redis" image (sourced from Dockerhub) using the "buster" tag, under a deployment named "cache-db", within the "CyberCo" namespace.
- Scales the "cache-db" deployment to have 2 replicas.
- Opens port "6379" on the "cache-db" containers.

**Notes:**
- The finalized solution will be assessed in a fresh, isolated environment. 

 
### Deliverables
- A brief README explaining the steps taken, any arguments used, and why you chose a particular Kubernetes distribution.

```

## 2. Linux Automation (Junior/Semi-Senior)

```bash

Scenario:

Complete the file stub located at `q2/runscript.sh` with one or more commands to achieve the following tasks:

- Extract the archive located at `/q2/backup.tar.gz`.
- Set permission "0664" for all the files that were just extracted.
- Set permission "0775" for all the directories that were just extracted.
- Change the owner to "anonymous" and the group to "no-team" for all the extracted files and directories.
- Create a new archive with the adjusted files and directories, naming it `/tmp/fixed-archive.tar.gz`.

**Notes:**

- Your solution will be evaluated in a new, clean setup. Make sure all work is performed in the `/q2` directory.
- Execute all tasks with a single `sudo activate` command run from within the question directory. (Hint: use alias)
- You have sudo permissions, if needed.

### Deliverables
- A brief README explaining the steps taken.
- `q2/runscript.sh` file modified 

```

## 3. Docker Multi-Stage Build Exercise (Semi-Senior)

```bash

### Context
You're a DevOps engineer working on a Node.js application. Your company is keen on optimising Docker images for production use.

### Objective
Create a Dockerfile that accomplishes the following:

1. Utilizes multi-stage builds for development and production.
2. In the first stage, named `builder`, use a Node.js image to install all dependencies and build the application. Assume that the build command is `npm run build`.
3. In the second stage, named `production`, use a smaller base image like `node:alpine` to set up the production environment. Copy only the essential files and folders from the `builder` stage.
4. Ensure that the production stage runs as a non-root user for added security.
5. Expose port `3000` for the application.
6. Make sure that the application starts with the command `npm start`.

### Constraints
- Your Dockerfile should be optimized for size and security.
- You can assume that a `.dockerignore` file is already set up to exclude unnecessary files.

### Bonus
- Include health checks in your Dockerfile.
- Use BuildKit features for added optimization, if you're familiar with them.

### Deliverables
- The Dockerfile.
- A brief README explaining the steps taken, any arguments used, and why you chose a particular base image or strategy.

```
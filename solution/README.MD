# Desafio DevOps Semperti - Solución

## Git

Procederemos a realizar un fork del repositorio original a otra cuenta de github donde se realizaran todos los cambios necesarios, ya sea la creacion de una nueva branch como los commits.

El paso final, una vez finalizados los ejercicios, sera generar un pull request al repositorio original con la rama solution.

Los pasos a seguir con git son:

```bash
# 1- Realizar Fork desde la web del repositorio original

# 2- Generar el clon del repo destino (en este caso mi github personal)
git clone https://github.com/gabriog/challenge-01.git

# 3- Crear la rama solution donde se trabajara en el challenge.
git checkout -b solution

# 4- Realizar los cambios necesarios (crear/modificar archivos). En este caso se utilizara vscode.

# 5- Impactar los cambios al repo personal.
git add .
git commit -m "texto que aluda al cambio"
git push origin solution

# 7- Generar Pull Request desde la pagina de nuestro repo
```


## 01. K8s deployment

Para el ejercicio es requisito contar con un ambiente de kubernetes, en este caso se utilizara minikube el cual se instalara en un ambiente de LinuxMint 22 con driver de virtualbox.

El paso de instalacion y despliegue es el siguiente:

```bash
gabo@T0003428893:~$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 29.1M  100 29.1M    0     0  5282k      0  0:00:05  0:00:05 --:--:-- 6742k

gabo@T0003428893:~$ sudo dpkg -i minikube_latest_amd64.deb
[sudo] password for gabo:          
Selecting previously unselected package minikube.
(Reading database ... 547052 files and directories currently installed.)
Preparing to unpack minikube_latest_amd64.deb ...
Unpacking minikube (1.34.0-0) ...
Setting up minikube (1.34.0-0) ...

gabo@T0003428893:~$ minikube start --driver=virtualbox
😄  minikube v1.34.0 on Linuxmint 22
✨  Using the virtualbox driver based on user configuration
💿  Downloading VM boot image ...
    > minikube-v1.34.0-amd64.iso....:  65 B / 65 B [---------] 100.00% ? p/s 0s
    > minikube-v1.34.0-amd64.iso:  333.55 MiB / 333.55 MiB  100.00% 6.58 MiB p/
👍  Starting "minikube" primary control-plane node in "minikube" cluster
💾  Downloading Kubernetes v1.31.0 preload ...
    > preloaded-images-k8s-v18-v1...:  326.69 MiB / 326.69 MiB  100.00% 6.30 Mi
🔥  Creating virtualbox VM (CPUs=2, Memory=3800MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
💡  kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Luego se procede a instalar kubectl para gestionar el cluster segun la documentación.

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /

sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt install kubectl
```

Para probar que minikube este desplegado:

```bash
gabo@T0003428893:~$ kubectl get nodes
NAME       STATUS   ROLES           AGE     VERSION
minikube   Ready    control-plane   3m10s   v1.31.0
gabo@T0003428893:~$ 
```

**NOTA:** Como aclara en la instalacion de minikube, no es necesario configurar kubectl en su ruta default (~/.kube/config).

A continuacion vemos el archivo yaml que se utilizara para realizar el deployment de redis.

**redis-deploy.yaml**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: CyberCo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
  namespace: CyberCo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:buster
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: CyberCo
spec:
  selector:
    app: redis
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
  type: ClusterIP
```

Como vemos, el deployment consta de 3 partes:
* Namespace: se crea el namespace **cyberco** sin especificar ninguna quota (por default no tiene restricciones de recursos). 
* Deployment: se especifica la creacion de un deployment de redis con 2 replicas.
* Service: se especifica un objeto de red que expone el conjunto de Pods de redis.

Para aplicar y corroborar el peployment seguimos estos pasos:

```bash
gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl apply -f redis-deployment.yaml 
namespace/cyberco created
deployment.apps/redis-deployment created
service/redis-service created

gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl get pods -n cyberco
NAME                               READY   STATUS    RESTARTS   AGE
redis-deployment-89cf98bdc-9m26s   1/1     Running   0          25s
redis-deployment-89cf98bdc-scqtd   1/1     Running   0          25s

gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl get svc -n cyberco
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
redis-service   ClusterIP   10.109.121.138   <none>        6379/TCP   8m18s
gabo@T0003428893:~/Workspace/challenge-01/solution$ 
```

Como se observa tenemos dos replicas de redis funcionales e independientes entre si ya que no sincronizan datos, el dato que se escribe en un pod solo queda almacenado en el mismo como vemos a continuacion:

```bash
gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl exec -it -n cyberco redis-deployment-89cf98bdc-9m26s -- /bin/bash

root@redis-deployment-89cf98bdc-9m26s:/data# redis-cli
127.0.0.1:6379> ping
PONG
127.0.0.1:6379> set perro "Maxi"
OK
127.0.0.1:6379> get perro
"Maxi"
127.0.0.1:6379> exit
root@redis-deployment-89cf98bdc-9m26s:/data# exit
exit

gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl exec -it -n cyberco redis-deployment-89cf98bdc-scqtd -- /bin/bash

root@redis-deployment-89cf98bdc-scqtd:/data# redis-cli
127.0.0.1:6379> get perro
(nil)
127.0.0.1:6379> exit
root@redis-deployment-89cf98bdc-scqtd:/data# exit
exit
```

Para mejorar esto, podemos aplicar esta configuracion de deployment:

**redis-deploy-sync.yaml**
```yaml:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-master
  namespace: cyberco
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-master
  template:
    metadata:
      labels:
        app: redis-master
    spec:
      containers:
      - name: redis
        image: redis:buster
        ports:
        - containerPort: 6379
        # Configuración del maestro
        command: ["redis-server"]
---
apiVersion: v1
kind: Service
metadata:
  name: redis-master
  namespace: cyberco
spec:
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
  selector:
    app: redis-master
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-slave
  namespace: cyberco
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-slave
  template:
    metadata:
      labels:
        app: redis-slave
    spec:
      containers:
      - name: redis
        image: redis:buster
        ports:
        - containerPort: 6379
        # Configuración del esclavo que se sincroniza con el maestro
        command:
          - redis-server
          - "--slaveof"
          - "redis-master"
          - "6379"
---
apiVersion: v1
kind: Service
metadata:
  name: redis-slave
  namespace: cyberco
spec:
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
  selector:
    app: redis-slave
```

La idea es configurar la replicación maestro-esclavo en redis dentro de Kubernetes, lo cual permite que una réplica actúe como el maestro y la otra como el esclavo.

* **Despliegue de Redis Master:** El maestro se despliega con el nombre redis-master.
El comando por defecto (redis-server) configura este nodo como el maestro de la réplica.
Se expone el puerto 6379 con un servicio ClusterIP.

* **Despliegue de Redis Slave:** El esclavo se despliega con el nombre redis-slave.
El comando redis-server --slaveof redis-master 6379 le dice al nodo que actúe como esclavo y que se sincronice con el maestro en el puerto 6379.
Al estar configurado como esclavo, Redis se sincroniza automáticamente con el maestro, recibiendo los cambios y actualizaciones.

* **Servicios de Redis Master y Slave:** Cada instancia (maestro y esclavo) tiene su propio servicio para acceder a ellas dentro del clúster.
El servicio para el maestro se llama redis-master, y el esclavo tiene el servicio redis-slave.

Procedemos a borrar el deployment anterior y aplicar el nuevo:

```bash
gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl delete -f redis-deploy.yaml 
namespace "cyberco" deleted
deployment.apps "redis-deployment" deleted
service "redis-service" deleted

gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl apply -f redis-deploy-sync.yaml 
namespace/cyberco created
deployment.apps/redis-master created
service/redis-master created
deployment.apps/redis-slave created
service/redis-slave created

gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl get all -n cyberco
NAME                               READY   STATUS    RESTARTS   AGE
pod/redis-master-5d4b69d68-w747h   1/1     Running   0          12s
pod/redis-slave-5b956db668-dhqkp   1/1     Running   0          12s

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/redis-master   ClusterIP   10.96.181.18   <none>        6379/TCP   12s
service/redis-slave    ClusterIP   10.106.36.49   <none>        6379/TCP   12s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/redis-master   1/1     1            1           12s
deployment.apps/redis-slave    1/1     1            1           12s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/redis-master-5d4b69d68   1         1         1       12s
replicaset.apps/redis-slave-5b956db668   1         1         1       12s
```

Realizamos las pruebas y vemos que efectivamente estan sincronizadas las replicas:

```bash
gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl exec -it -n cyberco redis-master-5d4b69d68-w747h -- /bin/bash
root@redis-master-5d4b69d68-w747h:/data# redis-cli
127.0.0.1:6379> ping
PONG
127.0.0.1:6379> set perro "Maxi"
OK
127.0.0.1:6379> get perro
"Maxi"
127.0.0.1:6379> exit
root@redis-master-5d4b69d68-w747h:/data# exit
exit

gabo@T0003428893:~/Workspace/challenge-01/solution$ kubectl exec -it -n cyberco redis-slave-5b956db668-dhqkp -- /bin/bash
root@redis-slave-5b956db668-dhqkp:/data# redis-cli
127.0.0.1:6379> get perro
"Maxi"
127.0.0.1:6379> 
```


## 02. Linux Automation

Creamos el script *runscript.sh* que cumpla con la consigna solicitada:

***runscript.sh***
```bash
#!/bin/bash

# Ruta al archivo que se va a extraer
TAR_FILE="./backup.tar.gz"

# Directorio de extracción
EXTRACT_DIR="./extracted"

# Verificar si el archivo existe
if [[ ! -f "$TAR_FILE" ]]; then
  echo "El archivo $TAR_FILE no existe."
  exit 1
fi

# Crear el directorio de extracción si no existe
mkdir -p $EXTRACT_DIR

# Extraer el archivo .tar.gz en el directorio de extracción
echo "Extrayendo $TAR_FILE en $EXTRACT_DIR..."
tar -xzvf $TAR_FILE -C $EXTRACT_DIR

# Verificar si el grupo 'no-team' existe, si no, crearlo
if ! getent group no-team > /dev/null; then
    sudo groupadd no-team
fi

# Verificar si el usuario 'anonymous' existe, si no, crearlo
if ! id "anonymous" &>/dev/null; then
    sudo useradd -g no-team anonymous
fi

# Cambiar propietario y grupo de los archivos y directorios extraídos
echo "Cambiando propietario y grupo a 'anonymous:no-team'..."
chown -R anonymous:no-team $EXTRACT_DIR

# Establecer permisos 0664 para todos los archivos extraídos
echo "Estableciendo permisos 0664 para los archivos..."
find $EXTRACT_DIR -type f -exec chmod 0664 {} \;

# Establecer permisos 0775 para todos los directorios extraídos
echo "Estableciendo permisos 0775 para los directorios..."
find $EXTRACT_DIR -type d -exec chmod 0775 {} \;

# Crear un nuevo archivo tar.gz con los archivos modificados
NEW_TAR="fixed-backup.tar.gz"
echo "Creando nuevo archivo comprimido $NEW_TAR..."
tar -czvf $NEW_TAR $EXTRACT_DIR/*

# Finalizar el script
echo "Proceso completado. El archivo modificado está en $NEW_TAR."
```

La idea es verificar si existe el archivo, caso contrario sale del script. Si el archivo existe, verifica si existe el usuario y el grupo (caso contrario los crea). Acto seguido, cambia usuario y grupo con *chown*, cambia los permisos de los directorios y de los archivos, finalmente genera un tar.gz con los archivos modificados. 

Antes de ejecutar el script, generamos el alias solicitado.

```bash
alias activate="sudo /home/gabo/Workspace/challenge-01/q2/runscript.sh"
```

Finalmente tipeamos *activate* para ejecutar el script realizado.

```bash
gabo@T0003428893:~/Workspace/challenge-01/q2$ ls -l
total 8
-rw-rw-r-- 1 gabo gabo  366 Sep 15 21:53 backup.tar.gz
-rwxrw-r-- 1 gabo gabo 1527 Sep 16 00:52 runscript.sh

gabo@T0003428893:~/Workspace/challenge-01/q2$ activate
Extrayendo ./backup.tar.gz en ./extracted...
dir_0/
dir_0/file_0.txt
dir_1/
dir_1/file_0.txt
dir_2/
dir_2/file_0.txt
dir_3/
dir_3/file_0.txt
dir_4/
dir_4/file_0.txt
dir_5/
dir_5/file_0.txt
file_0.txt
file_1.txt
file_2.txt
file_3.txt
file_4.txt
file_5.txt
file_6.txt
file_7.txt
file_8.txt
file_9.txt
Cambiando propietario y grupo a 'anonymous:no-team'...
Estableciendo permisos 0664 para los archivos...
Estableciendo permisos 0775 para los directorios...
Creando nuevo archivo comprimido fixed-backup.tar.gz...
./extracted/dir_0/
./extracted/dir_0/file_0.txt
./extracted/dir_1/
./extracted/dir_1/file_0.txt
./extracted/dir_2/
./extracted/dir_2/file_0.txt
./extracted/dir_3/
./extracted/dir_3/file_0.txt
./extracted/dir_4/
./extracted/dir_4/file_0.txt
./extracted/dir_5/
./extracted/dir_5/file_0.txt
./extracted/file_0.txt
./extracted/file_1.txt
./extracted/file_2.txt
./extracted/file_3.txt
./extracted/file_4.txt
./extracted/file_5.txt
./extracted/file_6.txt
./extracted/file_7.txt
./extracted/file_8.txt
./extracted/file_9.txt
Proceso completado. El archivo modificado está en fixed-backup.tar.gz.

gabo@T0003428893:~/Workspace/challenge-01/q2$ ls -l
total 16
-rw-rw-r-- 1 gabo      gabo     366 Sep 15 21:53 backup.tar.gz
drwxrwxr-x 8 anonymous no-team 4096 Sep 16 01:11 extracted
-rw-r--r-- 1 root      root     396 Sep 16 01:11 fixed-backup.tar.gz
-rwxrw-r-- 1 gabo      gabo    1527 Sep 16 00:52 runscript.sh

gabo@T0003428893:~/Workspace/challenge-01/q2$ ls -l extracted/
total 64
drwxrwxr-x 2 anonymous no-team 4096 Feb  1  2024 dir_0
drwxrwxr-x 2 anonymous no-team 4096 Feb  1  2024 dir_1
drwxrwxr-x 2 anonymous no-team 4096 Feb  1  2024 dir_2
drwxrwxr-x 2 anonymous no-team 4096 Feb  1  2024 dir_3
drwxrwxr-x 2 anonymous no-team 4096 Feb  1  2024 dir_4
drwxrwxr-x 2 anonymous no-team 4096 Feb  1  2024 dir_5
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_0.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_1.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_2.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_3.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_4.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_5.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_6.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_7.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_8.txt
-rw-rw-r-- 1 anonymous no-team    6 Feb  1  2024 file_9.txt
```


## 03. Docker Multi-Stage Build Exercise

Primero veamos el Dockerfile necesario:

```dockerfile
# Stage 1: Build the application
FROM node:18 AS builder

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install all dependencies
RUN npm install --production=false

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Set up the production environment
FROM node:18-alpine AS production

# Install curl for health check
RUN apk add --no-cache curl

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory
WORKDIR /app

# Copy only the essential files from the builder stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/app.js .

# Set the user to the non-root user
USER appuser

# Expose the application port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost:3000 || exit 1

# Start the application
CMD ["node", "app.js"]
```



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

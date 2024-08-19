#!/bin/bash

# Variables
user_chg="anonymous"
group_chg="no-team"
dir_destino="./backup/"

mkdir "$dir_destino"

tar -xzvf backup.tar.gz -C "$dir_destino"

#cd backup
cd "$dir_destino"
find -type f -exec chmod 0664 {} \;
find -type d -exec chmod 0775 {} \;
cd ..

# Verificar si el usuario y grupo existe, cambiar propietario y grupo

#if ! id -u "$user_chg" >/dev/null 2>&1; then
#               if ! getent group "$group_chg" >/dev/null 2>&1; then
#                               chown -R anonymous:no-team "$dir_destino"
#               else
#                               echo "El grupo '$group_chg' no existe."
#                               echo "No se cambia el propietario y grupo"
#               fi
#else
#    echo "El usuario '$user_chg' no existe."
#               echo "No se cambia el propietario y grupo"
#fi

if ! id -u "$user_chg" > /dev/null 2>&1; then
    useradd "$user_chg"
fi

if ! getent group "$group_chg" > /dev/null 2>&1; then
    groupadd "$group_chg"
fi

chown -R "$user_chg":"$group_chg" "$dir_destino"

tar -czvf /tmp/fixed-archive.tar.gz -C ./backup/ .
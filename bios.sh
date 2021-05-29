#!/bin/bash

print_help() {
    echo "Grabador de BIOS Lenovo Thinkpad en un medio USB."
    echo
    echo "Usage: $0 BIOS_ISO DEVICE"
    echo
    echo "- BIOS_ISO: archivo .iso que contiene la bios."
    echo "- DEVICE  : dispositivo donde se quiere grabar la bios para bootear."
    echo
}

clean_and_exit() {
    echo
    echo
    echo "----- Limpiando archivos.."
    rm -f geteltorito
    echo "listo"
    exit $1
}

download_geteltorito() {
    echo
    echo
    echo "----- Descargando herramienta geteltorito.."
    wget https://userpages.uni-koblenz.de/~krienke/ftp/noarch/geteltorito/geteltorito/geteltorito
    
    if [ $? -ne 0 ]
    then
        echo "----- ERROR: no se pudo realizar la descarga de geteltorito."
        exit 1
    fi
    
    chmod +x geteltorito
    echo "listo"
}

extract_image_from_iso() {
    ISO=$1
}

# Parseo de argumentos y verificacion de acceso root
if [ $# -eq 1 ] && ([ "$1" == "--help" ] || [ "$1" == "-h" ])
then
    print_help
    exit 0
elif [[ $EUID -ne 0 ]]
then
    echo "AVISO: Este script debe ser ejecutado como usuario root"
    echo "Ejecute sudo $0 ..."
    exit 1
elif [ $# -lt 2 ]
then
    print_help
    exit 1
elif [ ${1##*.} != "iso" ]
then
    print_help
    echo "----- ERROR: el argumento '$1' debe ser un archivo .iso"
    echo
    exit 1
fi

ISO=$1
DEV=$2

# Confirmacion antes de ejecutar
echo
echo "Se grabara el archivo: $ISO"
echo "en el dispositivo    : $DEV"
echo
while true
do
    read -p "Desea continuar? [y/n]: " -n 1 -r
    echo
    case $REPLY in
        y|Y) break;;
        n|N) exit 0;;
        *  ) echo "Invalido, elija 'y' o 'n'";;
    esac
done

download_geteltorito

clean_and_exit 0

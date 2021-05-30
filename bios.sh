#!/bin/bash
# https://github.com/anelioalvarez/burn-thinkpad-bios

print_help() {
    echo "Grabador de BIOS Lenovo Thinkpad en un medio USB."
    echo
    echo "Usage: $0 BIOS_ISO"
    echo
    echo "- BIOS_ISO: archivo .iso que contiene la bios."
    echo
}

clean_and_exit() {
    echo
    echo "### Limpiando archivos temporales.."
    rm -f geteltorito*
    rm -f $IMG
    echo "### OK"

    if [ $1 -eq 0 ]; then
        echo
        echo "COMPLETADO CON EXTIO."
    fi
    exit $1
}

download_geteltorito() {
    echo
    echo "### Descargando herramienta geteltorito.."
    wget https://userpages.uni-koblenz.de/~krienke/ftp/noarch/geteltorito/geteltorito/geteltorito
    
    if [ $? -ne 0 ]; then
        echo "### ERROR: no se pudo realizar la descarga de geteltorito."
        exit 1
    fi
    
    chmod +x geteltorito
    echo "### OK"
}

extract_image_from_iso() {
    echo
    echo "### Extrayendo la imagen desde el arhivo ISO.."
    ./geteltorito -o $IMG $ISO

    if [ $? -ne 0 ]; then
        echo "### ERROR: el archivo ISO ingresado no es valido."
        clean_and_exit 1
    fi
    echo "### OK"
}

write_image_toUSB() {
    echo
    echo "### Desmontando $DEVICE.."
    ls ${DEVICE}?* | xargs -n1 umount -l
    echo "### OK"; echo

    echo "### Escribiendo la imagen en dispositivo USB $DEVICE.."
    dd if=$IMG of=$DEVICE bs=64K status=progress

    if [ $? -ne 0 ]; then
        echo "### ERROR: no se pudo escribir la imagen."
        clean_and_exit 1
    fi
    echo "### OK"
}

select_USBdevice() {
    DEVICES_INFO=$(grep -Ff <(hwinfo --disk --short) <(hwinfo --usb --short) | tail -n+2 | awk '{print NR")", $0}')

    if [ -z "$DEVICES_INFO" ]; then
        print_help
        echo "### ERROR: No se encontraron dispositivos USB para grabar la bios."
        echo "           Conecte un dispositivo USB y vuelva a ejecutar."
        exit 1
    fi
    
    mapfile -t USBS < <(awk '{print $2}' <<< $DEVICES_INFO)

    #for elem in "${USBS[@]}"
    #do
    #	echo "$elem"
    #done

    # Menu de opciones
    echo "USBs encontrados: ${#USBS[@]}"
    echo "$DEVICES_INFO"
    echo "q.   salir"; echo

    # Se selecciona el usb
    while true; do
    read -p "Seleccione: " -n 1 -r
    echo
    case $REPLY in
        [0-9])
            if [ $REPLY -ge 1 ] && [ $REPLY -le ${#USBS[@]} ]; then
                DEVICE=${USBS[$REPLY-1]}
                break
            fi
            echo "Invalido: debe ser numero entre 1 y ${#USBS[@]}";;
        q|Q) echo; echo "Saliendo.."; exit 0;;
        *  ) echo "Invalido: debe ser numero entre 1 y ${#USBS[@]}";;
    esac
    done

    echo
    echo "USB seleccionado: $DEVICE"
    echo "### IMPORTANTE: se perdera toda la informacion almacenada en el dispositivo"
    echo
    read -p "Continuar?: [y/n] " -n 1 -r
        echo
        case $REPLY in
            y|Y) ;;
            *  ) echo; echo "Saliendo.."; exit 0;;
        esac
}


# Parseo de argumentos y verificacion de acceso root
if [ $# -lt 1 ]; then
    print_help
    exit 1
elif [ $# -eq 1 ] && ([ "$1" == "--help" ] || [ "$1" == "-h" ]); then
    print_help
    exit 0
elif [[ $EUID -ne 0 ]]; then
    echo "### AVISO: Este script debe ser ejecutado como usuario root"
    echo "Ejecute sudo $0 ..."
    exit 1
elif [ ${1##*.} != "iso" ]; then
    print_help
    echo "### ERROR: el argumento '$1' debe ser un archivo .iso"
    echo
    exit 1
elif [ ! -f $1 ]; then
    print_help
    echo "### ERROR: el archivo '$1' no existe"
    echo
    exit 1
fi


ISO=$1
IMG=${ISO##*/}    # archivo base
IMG=${IMG%.*}.img # extension iso -> img

select_USBdevice

download_geteltorito

extract_image_from_iso

write_image_toUSB

clean_and_exit 0

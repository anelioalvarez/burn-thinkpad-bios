### Flasheador de BIOS en medio USB
Script para facilitar el proceso de actualizacion de Bios de notebooks **Lenovo Thinkpad** en Linux.

Siguiendo estos pasos podras generar un medio USB booteable con la nueva bios descargada desde la pagina oficial de Lenovo.


## Instrucciones
1. obtener el numero de serie de tu Thinkpad: `sudo dmidecode -s system-serial-number`
2. dirigirse a https://pcsupport.lenovo.com
3. usar el numero de serie para descargar el iso con la Bios: **Drivers & Software > BIOS/UEFI > BIOS Update (Bootable CD)**
4. conectar un **dispositivo USB** donde se va a flashear la bios (**WARN: se borrara la informacion almacenada**)
5. clonar el repo: `git clone https://github.com/anelioalvarez/burn-thinkpad-bios.git`
6. `cd burn-thinkpad-bios`
7. `sudo ./bios.sh <ubicacion del .iso>`
8. seguir los pasos que se indican para completar el proceso de flasheo
9. reiniciar y bootear desde el usb para proceder a la actualizacion de bios
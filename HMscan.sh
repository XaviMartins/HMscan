#!/bin/bash

# Función para mostrar una animación de carga
loading_animation() {
    local word=$1
    local length=${#word}
    local display=""
    local loading_chars="----------------------------------------"

    # Limpiar la línea
    echo -ne "\r$loading_chars"

    for (( i=0; i<$length; i++ )); do
        # Agregar la letra actual al display
        display="$display${word:$i:1}"

        # Limpiar la línea y mostrar el display actual
        echo -ne "\r$display"

        # Esperar un momento
        sleep 0.1
    done

    # Salto de línea al final
    echo ""
}

# Llamar a la Animacion "XAVI MARTINS"
echo 'CREADO PARA LA ACADEMIA HACKER MENTOR POR:'
loading_animation "XAVI MARTINS (JM)"

# Script de Escaneo con Nmap

echo 'SCRIPT DE ESCANEO CON NMAP PARA PENTESTER MENTOR JUNIOR (PMJ)'
echo '---------------------------------------'
echo 'Ingrese la dirección IP a escanear: '
read target
echo ''

# Escaneo sigiloso de puertos
echo 'Ejecutando un escaneo sigiloso de puertos...'
echo 'Comando ejecutado: (sudo nmap -sS --min-rate 800 -n -p- --open -v -O -Pn' $target '-oN allPorts)'
echo '---------------------------------------'
sudo nmap -sS --min-rate 800 -n -p- --open -v -O -Pn $target -oN allPorts

# Extrayendo puertos abiertos
echo ''
echo '---------------------------------------'
echo 'Extrayendo puertos abiertos...'
echo "Comando ejecutado: (grep '/tcp' allPorts | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')"
echo '---------------------------------------'
open_ports=$(grep '/tcp' allPorts | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

echo 'Puertos abiertos: ' $open_ports
echo '---------------------------------------'

# Reconociendo servicios y versiones
echo 'Reconociendo Servicios y Versiones...'
echo 'Comando ejecutado: (sudo nmap -sV -sC -p'$open_ports' -n -v -Pn' $target '-oA nmap-results)'
echo '---------------------------------------'
sudo nmap -sV -sC -p$open_ports -n -v -Pn $target -oA nmap-results

# Consulta antes de exportar resultados a HTML
echo ''
echo '---------------------------------------'
read -t 10 -p '¿Desea exportar los resultados en formato HTML? (y/n): ' export_choice
export_choice=${export_choice:-y}
if [ "$export_choice" == "Y" ] || [ "$export_choice" == "y" ]; then
    echo 'Exportando Resultados en formato HTML...'
    echo 'Comando ejecutado: (xsltproc nmap-results.xml -o nmap-results.html)'
    xsltproc nmap-results.xml -o nmap-results.html
    echo '---------------------------------------'
fi

# Consulta antes de ejecutar scripts Vuln y Safe de Nmap
read -t 10 -p "¿Desea ejecutar los scripts de categorías Vuln y Safe de Nmap? (y/n): " choice
choice=${choice:-y}
if [[ $choice == 'y' || $choice == 'Y' ]]; then
    echo "Analizando Vulnerabilidades con los scripts de categorías Vuln y Safe de Nmap..."
    echo 'Comando ejecutado: (sudo nmap --script="safe and vuln" -n -p'$open_ports '-v -Pn '$target '-oN vulnScan)'
    vuln_result=$(sudo nmap --script="safe and vuln" -n -p$open_ports -v -Pn $target -oN vulnScan)
    cat vulnScan
    echo '---------------------------------------'
fi

echo '---------------------------------------'
echo ''
echo 'RESUMEN FINAL IP' $target
echo '---------------------------------------'
echo ''

# Intentar encontrar el sistema operativo en el archivo allPorts
os_info=$(grep -i 'OS details:' allPorts | cut -d ":" -f 2-)

# Si no se encuentra en allPorts, intentar encontrarlo en nmap-results.nmap
if [ -z "$os_info" ]; then
    os_info=$(grep -i 'Service Info:' nmap-results.nmap | awk -F': ' '{print $4}')
fi

# Si aún no se encuentra, intentar encontrarlo en otro archivo (por ejemplo, vulnScan)
if [ -z "$os_info" ]; then
    os_info=$(grep -i 'Service Info:' vulnScan | awk -F': ' '{print $4}')
fi

# Mostrar la información del sistema operativo si se encuentra
if [ ! -z "$os_info" ]; then
    echo "Sistema Operativo Detectado:" $os_info
else
    echo "Sistema Operativo no detectado."
fi

# Mostrando puertos, servicios y versiones levantados
echo ''
echo 'Puertos Abiertos, Servicios y Versiones:'
grep '/tcp' nmap-results.nmap | awk '{print $1, $3, $4, $5, $6, $7}' | while read line; do
    echo "- $line"
done
echo '---------------------------------------'
echo ''

echo ''
echo '¡Escaneo completo!'
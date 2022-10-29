#!/bin/bash

function ctrl_c(){
  echo -e "\n\n[!] Saliendo ...\n"
  tput cnorm; exit 1
}

# Ctrl+C
trap ctrl_c INT

# Global Variables
hosts=(172.18.0.1 172.18.0.2 172.19.0.1 172.19.0.2 172.19.0.3 172.19.0.4)
networks=(172.20.0)


# Functions
function helpPanel(){
  echo -e "\n[+] Use:\n"
  echo -e "\t -n) Scan Network mode: Find host inside a network(s)"
  echo -e "\t -p) Scan Ports mode: Find open ports inside a host(s)"
  echo -e "\n[!] Before execute you have to edit the targeted networks and hosts on the global variables of this script"
}

function scanNetwork(){
  tput civis; for network in ${networks[@]}; do
    echo -e "\n[+] Enumerando la network $network.0/24:"
    for i in $(seq 1 254); do
      timeout 1 bash -c "ping -c 1 $network.$i" &>/dev/null && echo -e "\t[+] Host $network.$i - ACTIVE" &
    done; wait
  done; tput cnorm
}

function scanHosts(){
  tput civis; for host in ${hosts[@]}; do
    echo -e "\n[+] Enumerando puertos para el host $host:"
    for port in $(seq 1 10000); do
      timeout 1 bash -c "echo '' > /dev/tcp/$host/$port" 2>/dev/null && echo -e "\t[+] Port $port - OPEN" &
    done; wait
  done; tput cnorm
}

# Functional Variables
parameter_counter=0

# Cases
while getopts "nph" arg; do
  case $arg in
    n) let parameter_counter+=1;;
    p) let parameter_counter+=2;;
    h) ;;
  esac
done
  
if [ $parameter_counter -eq 1 ]; then
  scanNetwork
elif [ $parameter_counter -eq 2 ]; then
  scanHosts
else
  helpPanel
fi

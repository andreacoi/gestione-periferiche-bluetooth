#!/bin/bash

while true; do
  # Comando o script da eseguire ogni secondo
  /home/andrea/sys/autostart/gestisci-periferiche/gestisci-tastiera-bt-laptop.sh
  /home/andrea/sys/autostart/gestisci-periferiche/gestisci-mouse-bt-laptop.sh

  # Pausa di 1 secondo
  sleep 1
done

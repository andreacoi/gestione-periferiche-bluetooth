#!/bin/bash
# Nome o parte del nome della tastiera Bluetooth
MAC_TASTIERA_BLUETOOTH_LOGITECH="D8:8B:4D:EA:76:87"
# Nome o parte del nome della tastiera del laptop - da cat /proc/devices/ risulta standard come AT Translated Set 2 keyboard
LAPTOP_KEYBOARD_NAME="AT Translated Set 2 keyboard"
# Nome fisico della tastiera integrata, equiparabile al MAC ADDRESS
PHYSICAL_INTEGRATED_KEYBOARD_NAME="isa0060/serio0/input0"
# Controlla se il dispositivo Bluetooth specificato è connesso
is_tastiera_connected=$(bluetoothctl info $MAC_TASTIERA_BLUETOOTH_LOGITECH | grep "Connected" | awk '{print $2}')
# Verifico la sessione attualmente attiva - se X11 posso utilizzare xinput altrimenti no - PRIMA CONDIZIONE: wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  # A partire dal PHYSICAL_INTEGRATED_KEYBOARD_NAME ottengo il numero dell'event presente in /org/kde/KWin/InputDevice che potrebbe variare ad ogni avvio della macchina
  event_tastiera=$(cat /proc/bus/input/devices | awk -v phys="$PHYSICAL_INTEGRATED_KEYBOARD_NAME" '/Phys='"$phys"'/{flag=1} flag && /Handlers/{print $5; exit}')
  # verifica lo stato della tastiera del portatile (abilitato o disabilitato)
  stato_tastiera_portatile=$(qdbus org.kde.KWin /org/kde/KWin/InputDevice/$event_tastiera org.freedesktop.DBus.Properties.Get org.kde.KWin.InputDevice enabled)
  # inizia con il PRIMO ciclo if - verifica che la tastiera bluetooth LOGITECH - vedi MAC riga 3 sia connessa.
  if [ "$is_tastiera_connected" == "yes" ]; then
    # se il mouse bluetooth è attivo, verifica che il touchpad del portatile sia attivo.
    if [ "$stato_tastiera_portatile" == "true" ]; then
      # se la tastiera del portatile è attiva disabilitala tramite DBus
      qdbus org.kde.KWin /org/kde/KWin/InputDevice/$event_tastiera org.freedesktop.DBus.Properties.Set org.kde.KWin.InputDevice enabled false
    fi
  else
    # se il mouse bluetooth, al contrario, è disattivo verifico lo stato_tastiera_portatile
    if [ "$stato_tastiera_portatile" == "false" ]; then
      # se lo stato_tastiera_portatile è disattivo, lo abilito, sempre utilizzando DBus
      qdbus org.kde.KWin /org/kde/KWin/InputDevice/$event_tastiera org.freedesktop.DBus.Properties.Set org.kde.KWin.InputDevice enabled true
    fi
  fi
# verifica la seconda condizione inerente al tipo di sessione - X11
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
  stato_tastiera_portatile=$(xinput list-props "$LAPTOP_KEYBOARD_NAME" | grep "Device Enabled" | awk '{print $4}')

  if [ "$is_tastiera_connected" == "yes" ]; then
    # se il mouse bluetooth è attivo, verifica che il touchpad del portatile sia attivo.
    if [ "$stato_tastiera_portatile" -eq 1 ]; then
      # se il touchpad Synaptics è attivo disabilitalo tramite xinput per via della sessione X11
      xinput disable "$LAPTOP_KEYBOARD_NAME"
    fi
  else
    # se il mouse bluetooth, al contrario, è disattivo verifico lo stato_touchpad_portatile
    if [ "$stato_tastiera_portatile" -eq 0 ]; then
      # se lo stato_touchpad_portatile è disattivo, lo abilito, tramite xinput per via della sessione X11
      xinput enable "$LAPTOP_TOUCHPAD_NAME"
    fi
  fi
  # se, invece, la sessione non è nè wayland nè x11, stampo un semplice messaggio.
else
  echo "Ambiente sconosciuto: $XDG_SESSION_TYPE"
fi

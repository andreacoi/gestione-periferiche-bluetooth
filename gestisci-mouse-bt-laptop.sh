#!/bin/bash
# Nome o parte del nome della tastiera Bluetooth
MOUSE_BLUETOOTH_LOGITECH_MAC="F3:C6:28:30:A8:41"
# Nome o parte del nome del touchpad del laptop - da cat /proc/bus/input/devices risulta standard come Synaptics TM3336-005
LAPTOP_TOUCHPAD_NAME="Synaptics TM3336-005"
# Nome fisico del touchpad, equiparabile al MAC ADDRESS
PHYSICAL_TOUCHPAD_NAME="i2c-SYNA2B5E:00"
# Controlla se il dispositivo Bluetooth specificato è connesso
is_mouse_connected=$(bluetoothctl info $MOUSE_BLUETOOTH_LOGITECH_MAC | grep "Connected" | awk '{print $2}')
# Verifico la sessione attualmente attiva - se X11 posso utilizzare xinput altrimenti no - PRIMA CONDIZIONE: wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  # A partire dal PHYSICAL_TOUCHPAD_NAME ottengo il numero dell'event presente in /org/kde/KWin/InputDevice che varia ad ogni avvio della macchina
  event_touchpad=$(cat /proc/bus/input/devices | awk '/Phys='$PHYSICAL_TOUCHPAD_NAME'/{flag=1} flag && /Handlers/{print $3; exit}')
  # verifica lo stato del touchpad del portatile (abilitato o disabilitato)
  stato_touchpad_portatile=$(qdbus org.kde.KWin /org/kde/KWin/InputDevice/$event_touchpad org.freedesktop.DBus.Properties.Get org.kde.KWin.InputDevice enabled)
  # inizia con il PRIMO ciclo if - verifica che il mouse bluetooth LOGITECH - vedi MAC riga 3 sia connesso.
  if [ "$is_mouse_connected" == "yes" ]; then
    # se il mouse bluetooth è attivo, verifica che il touchpad del portatile sia attivo.
    if [ "$stato_touchpad_portatile" == "true" ]; then
      # se il touchpad Synaptics è attivo disabilitalo tramite DBus
      qdbus org.kde.KWin /org/kde/KWin/InputDevice/event5 org.freedesktop.DBus.Properties.Set org.kde.KWin.InputDevice enabled false
    fi
  else
    # se il mouse bluetooth, al contrario, è disattivo verifico lo stato_touchpad_portatile
    if [ "$stato_touchpad_portatile" == "false" ]; then
      # se lo stato_touchpad_portatile è disattivo, lo abilito, sempre utilizzando DBus
      qdbus org.kde.KWin /org/kde/KWin/InputDevice/event5 org.freedesktop.DBus.Properties.Set org.kde.KWin.InputDevice enabled true
    fi
  fi
# verifica la seconda condizione inerente al tipo di sessione - X11
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
  # Controlla lo stato del touchpad del laptop
  stato_touchpad_portatile=$(xinput list-props "$LAPTOP_TOUCHPAD_NAME" | grep "Device Enabled" | awk '{print $4}')
  # inizia con il PRIMO ciclo if - verifica che il mouse bluetooth LOGITECH - vedi MAC riga 3 sia connesso.
  if [ "$is_mouse_connected" == "yes" ]; then
    # se il mouse bluetooth è attivo, verifica che il touchpad del portatile sia attivo.
    if [ "$stato_touchpad_portatile" -eq 1 ]; then
      # se il touchpad Synaptics è attivo disabilitalo tramite xinput per via della sessione X11
      xinput disable "$LAPTOP_TOUCHPAD_NAME"
    fi
  else
    # se il mouse bluetooth, al contrario, è disattivo verifico lo stato_touchpad_portatile
    if [ "$stato_touchpad_portatile" -eq 0 ]; then
      # se lo stato_touchpad_portatile è disattivo, lo abilito, tramite xinput per via della sessione X11
      xinput enable "$LAPTOP_TOUCHPAD_NAME"
    fi
  fi
  # se, invece, la sessione non è nè wayland nè x11, stampo un semplice messaggio.
else
  echo "Ambiente sconosciuto: $XDG_SESSION_TYPE"
fi

#!/bin/bash

# Nome o parte del nome della tastiera Bluetooth
MOUSE_BLUETOOTH_LOGITECH_MAC="F3:C6:28:30:A8:3F"

# Nome o parte del nome della tastiera del laptop - da xinput risulta standard come AT Translated Set 2 keyboard
LAPTOP_TOUCHPAD_NAME="Synaptics TM3336-005"

# Controlla se il dispositivo Bluetooth specificato è connesso
is_mouse_connected=$(bluetoothctl info $MOUSE_BLUETOOTH_LOGITECH_MAC | grep "Connected" | awk '{print $2}')

# Controlla lo stato della tastiera del laptop
stato_touchpad_portatile=$(xinput list-props "$LAPTOP_TOUCHPAD_NAME" | grep "Device Enabled" | awk '{print $4}')

if [ "$is_mouse_connected" == "yes" ]; then
  if [ "$stato_touchpad_portatile" -eq 1 ]; then
    xinput disable "$LAPTOP_TOUCHPAD_NAME"
  fi
else
  if [ "$stato_touchpad_portatile" -eq 0 ]; then
    xinput enable "$LAPTOP_TOUCHPAD_NAME"
  fi
fi

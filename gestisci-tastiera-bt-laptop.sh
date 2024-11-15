#!/bin/bash

# Nome o parte del nome della tastiera Bluetooth
TASTIERA_BLUETOOTH_LOGITECH="MX MCHNCL M"

# Nome o parte del nome della tastiera del laptop - da xinput risulta standard come AT Translated Set 2 keyboard
LAPTOP_KEYBOARD_NAME="AT Translated Set 2 keyboard"

# Controlla se il dispositivo Bluetooth specificato è connesso
is_keyboard_connected=$(bluetoothctl info | grep -q "Name: $TASTIERA_BLUETOOTH_LOGITECH" && echo "yes" || echo "no")

# Controlla lo stato della tastiera del laptop
stato_tastiera_portatile=$(xinput list-props "$LAPTOP_KEYBOARD_NAME" | grep "Device Enabled" | awk '{print $4}')

if [ "$is_keyboard_connected" == "yes" ]; then
  if [ "$stato_tastiera_portatile" -eq 1 ]; then
    xinput disable "$LAPTOP_KEYBOARD_NAME"
  fi
else
  if [ "$stato_tastiera_portatile" -eq 0 ]; then
    xinput enable "$LAPTOP_KEYBOARD_NAME"
  fi
fi

#!/usr/bin/env bash

if [[ ! $(pidof rofi) ]]; then
  rofi -show drun -config ~/.config/rofi/menu.rasi
else
  pkill rofi
fi

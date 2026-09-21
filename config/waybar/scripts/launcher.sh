#!/usr/bin/env bash

if [[ ! $(pidof fuzzel) ]]; then
  fuzzel --config ~/.config/fuzzel/launcher.ini
else
  pkill fuzzel
fi

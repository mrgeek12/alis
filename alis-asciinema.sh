#!/usr/bin/env bash
set -e

# Сценарий установки Arch Linux (alis) устанавливает автоматическую, автоматическую установку.
# и настроенная система Arch Linux.
# Copyright (C) 2021 picodotdev

#curl -L -o asciinema-2.0.2.zip https://github.com/asciinema/asciinema/archive/v2.0.2.zip
#bsdtar xvf asciinema-2.0.2.zip
#rm -f alis.asciinema
#(cd asciinema-2.0.2 && python3 -m asciinema rec --stdin -i 5 ~/alis.asciinema)

rm -f alis.asciinema

pacman -Sy
pacman -S --noconfirm asciinema

clear
asciinema rec --stdin -i 5 ~/alis.asciinema

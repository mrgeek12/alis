#!/usr/bin/env bash
set -e

# Сценарий восстановления Arch Linux (alis) устанавливает автоматическую установку,
# и настройку системы Arch Linux.
# Copyright (C) 2021 picodotdev

function do_reboot() {
    umount -R /mnt/boot
    umount -R /mnt
    reboot
}

do_reboot

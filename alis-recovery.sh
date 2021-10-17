#!/usr/bin/env bash
set -e

# Сценарий восстановления Arch Linux (alis) устанавливает автоматическую установку,
# и настройку системы Arch Linux.
# Copyright (C) 2021 picodotdev

# Это бесплатное программное обеспечение: вы можете распространять и / или изменять
# это в соответствии с условиями Стандартной общественной лицензии GNU,
# опубликованной Free Software Foundation, либо версии 3 Лицензии, либо
# (по вашему выбору) любой более поздней версии.
#
# Эта программа распространяется в надежде, что она будет полезной,
# но БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ; даже без подразумеваемой гарантии
# ТОВАРНОЙ ПРИГОДНОСТИ или ПРИГОДНОСТИ ДЛЯ КОНКРЕТНОЙ ЦЕЛИ. Подробнее см.
# Стандартную общественную лицензию GNU.
#
# Вы должны были получить копию Стандартной общественной лицензии GNU
# вместе с этой программой. Если нет, см. <Http://www.gnu.org/licenses/>.

# Этот скрипт размещен по адресу https://github.com/mrgeek12/alis. Для новых функций
# улучшений и ошибок, заполните проблему в GitHub или сделайте запрос на перенос.
# Pull Request приветствуются!
#
# Если вы тестируете его на реальном оборудовании, пришлите мне письмо на mr.geek1@protonmail.com с
# описанием машины и сообщите мне, если что-то пойдет не так или все работает нормально.
#
# Пожалуйста, не просите поддержки для этого скрипта на форумах Arch Linux, сначала прочтите
# вики Arch Linux [1], Руководство по установке [2] и Общие
# Рекомендации [3], позже сравните команды с командами этого скрипта.
#
# [1] https://wiki.archlinux.org
# [2] https://wiki.archlinux.org/index.php/Installation_guide
# [3] https://wiki.archlinux.org/index.php/General_recommendations

# Использование:
# # loadkeys ru
# # iwctl --passphrase "[WIFI_KEY]" station [WIFI_INTERFACE] connect "[WIFI_ESSID]"
# (Необязательно) Подключитесь к сети Wi-Fi. _ip link show_ узнать WIFI_INTERFACE.
# # curl https://raw.githubusercontent.com/mrgeek12/alis/master/download.sh | bash, curl https://raw.githubusercontent.com/mrgeek12/alis/master/download.sh | bash -s -- -u [github user], или сокращенная ссылка curl -sL https://bit.ly/2F3CATp | bash
# # nano alis-recovery.conf
# # ./alis-recovery.sh

# глобальные переменные (без конфигурации, не редактировать)
ASCIINEMA=""
BIOS_TYPE=""
PARTITION_BOOT=""
PARTITION_ROOT=""
PARTITION_BOOT_NUMBER=""
PARTITION_ROOT_NUMBER=""
DEVICE_ROOT=""
DEVICE_LVM=""
LUKS_DEVICE_NAME="cryptroot"
LVM_VOLUME_GROUP="vg"
LVM_VOLUME_LOGICAL="root"
BOOT_DIRECTORY=""
ESP_DIRECTORY=""
#PARTITION_BOOT_NUMBER=0
UUID_BOOT=""
UUID_ROOT=""
PARTUUID_BOOT=""
PARTUUID_ROOT=""
DEVICE_SATA=""
DEVICE_NVME=""
DEVICE_MMC=""
CPU_VENDOR=""
VIRTUALBOX=""
CMDLINE_LINUX_ROOT=""
CMDLINE_LINUX=""
ADDITIONAL_USER_NAMES_ARRAY=()
ADDITIONAL_USER_PASSWORDS_ARRAY=()

CONF_FILE="alis-recovery.conf"
GLOBALS_FILE="alis-globals.conf"
LOG_FILE="alis-recovery.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function configuration_install() {
    source "$CONF_FILE"
}

function sanitize_variables() {
    DEVICE=$(sanitize_variable "$DEVICE")
    PARTITION_MODE=$(sanitize_variable "$PARTITION_MODE")
    PARTITION_CUSTOMMANUAL_BOOT=$(sanitize_variable "$PARTITION_CUSTOMMANUAL_BOOT")
    PARTITION_CUSTOMMANUAL_ROOT=$(sanitize_variable "$PARTITION_CUSTOMMANUAL_ROOT")
}

function sanitize_variable() {
    VARIABLE=$1
    VARIABLE=$(echo $VARIABLE | sed "s/![^ ]*//g") # удалить отключено
    VARIABLE=$(echo $VARIABLE | sed "s/ {2,}/ /g") # удалить ненужные пробелы
    VARIABLE=$(echo $VARIABLE | sed 's/^[[:space:]]*//') # обрезать ведущий
    VARIABLE=$(echo $VARIABLE | sed 's/[[:space:]]*$//') # обрезать трейлинг
    echo "$VARIABLE"
}

function check_variables() {
    check_variables_value "KEYS" "$KEYS"
    check_variables_value "DEVICE" "$DEVICE"
    check_variables_boolean "LVM" "$LVM"
    check_variables_equals "LUKS_PASSWORD" "LUKS_PASSWORD_RETYPE" "$LUKS_PASSWORD" "$LUKS_PASSWORD_RETYPE"
    check_variables_list "PARTITION_MODE" "$PARTITION_MODE" "auto custom manual" "true"
    if [ "$PARTITION_MODE" == "custom" ]; then
        check_variables_value "PARTITION_CUSTOM_PARTED_UEFI" "$PARTITION_CUSTOM_PARTED_UEFI"
        check_variables_value "PARTITION_CUSTOM_PARTED_BIOS" "$PARTITION_CUSTOM_PARTED_BIOS"
    fi
    if [ "$PARTITION_MODE" == "custom" -o "$PARTITION_MODE" == "manual" ]; then
        check_variables_value "PARTITION_CUSTOMMANUAL_BOOT" "$PARTITION_CUSTOMMANUAL_BOOT"
        check_variables_value "PARTITION_CUSTOMMANUAL_ROOT" "$PARTITION_CUSTOMMANUAL_ROOT"
    fi
    if [ "$LVM" == "true" ]; then
        check_variables_list "PARTITION_MODE" "$PARTITION_MODE" "auto" "true"
    fi
    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
}

function check_variables_value() {
    NAME=$1
    VALUE=$2
    if [ -z "$VALUE" ]; then
        echo "$NAME environment variable must have a value."
        exit
    fi
}

function check_variables_boolean() {
    NAME=$1
    VALUE=$2
    check_variables_list "$NAME" "$VALUE" "true false"
}

function check_variables_list() {
    NAME=$1
    VALUE=$2
    VALUES=$3
    REQUIRED=$4
    if [ "$REQUIRED" == "" -o "$REQUIRED" == "true" ]; then
        check_variables_value "$NAME" "$VALUE"
    fi

    if [ "$VALUE" != "" -a -z "$(echo "$VALUES" | grep -F -w "$VALUE")" ]; then
        echo "$NAME environment variable value [$VALUE] must be in [$VALUES]."
        exit
    fi
}

function check_variables_equals() {
    NAME1=$1
    NAME2=$2
    VALUE1=$3
    VALUE2=$4
    if [ "$VALUE1" != "$VALUE2" ]; then
        echo "$NAME1 and $NAME2 must be equal [$VALUE1, $VALUE2]."
        exit
    fi
}

function check_variables_size() {
    NAME=$1
    SIZE_EXPECT=$2
    SIZE=$3
    if [ "$SIZE_EXPECT" != "$SIZE" ]; then
        echo "$NAME array size [$SIZE] must be [$SIZE_EXPECT]."
        exit
    fi
}

function warning() {
    echo -e "${LIGHT_BLUE}Welcome to Arch Linux Install Script Recovery${NC}"
    echo ""
    echo "Once finalized recovery tasks execute following commands: exit, umount -R /mnt, reboot."
    echo ""
    read -p "Do you want to continue? [y/N] " yn
    case $yn in
        [Yy]* )
            ;;
        [Nn]* )
            exit
            ;;
        * )
            exit
            ;;
    esac
}

function init() {
    init_log
    loadkeys $KEYS
}

function init_log() {
    if [ "$LOG" == "true" ]; then
        exec > >(tee -a $LOG_FILE)
        exec 2> >(tee -a $LOG_FILE >&2)
    fi
    set -o xtrace
}

function facts() {
    if [ -d /sys/firmware/efi ]; then
        BIOS_TYPE="uefi"
    else
        BIOS_TYPE="bios"
    fi

    DEVICE_SATA="false"
    DEVICE_NVME="false"
    DEVICE_MMC="false"
    if [ -n "$(echo $DEVICE | grep "^/dev/[a-z]d[a-z]")" ]; then
        DEVICE_SATA="true"
    elif [ -n "$(echo $DEVICE | grep "^/dev/nvme")" ]; then
        DEVICE_NVME="true"
    elif [ -n "$(echo $DEVICE | grep "^/dev/mmc")" ]; then
        DEVICE_MMC="true"
    fi

    if [ -n "$(lscpu | grep GenuineIntel)" ]; then
        CPU_INTEL="true"
    fi

    if [ -n "$(lspci | grep -i virtualbox)" ]; then
        VIRTUALBOX="true"
    fi
}

function check_facts() {
}

function prepare() {
    prepare_partition
    configure_network
    ask_passwords
}

function prepare_partition() {
    if [ -d /mnt/boot ]; then
        umount /mnt/boot
        umount /mnt
    fi
    if [ -e "/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL" ]; then
        umount "/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
    fi
    if [ -e "/dev/mapper/$LUKS_DEVICE_NAME" ]; then
        cryptsetup close $LUKS_DEVICE_NAME
    fi
    partprobe $DEVICE
}

function configure_network() {
    if [ -n "$WIFI_INTERFACE" ]; then
        iwctl --passphrase "$WIFI_KEY" station $WIFI_INTERFACE connect "$WIFI_ESSID"
        sleep 10
    fi

    ping -c 1 -i 2 -W 5 -w 30 $PING_HOSTNAME
    if [ $? -ne 0 ]; then
        echo "Network ping check failed. Cannot continue."
        exit
    fi
}

function ask_passwords() {
    if [ "$LUKS_PASSWORD" == "ask" ]; then
        PASSWORD_TYPED="false"
        while [ "$PASSWORD_TYPED" != "true" ]; do
            read -sp 'Type LUKS password: ' LUKS_PASSWORD
            echo ""
            read -sp 'Retype LUKS password: ' LUKS_PASSWORD_RETYPE
            echo ""
            if [ "$LUKS_PASSWORD" == "$LUKS_PASSWORD_RETYPE" ]; then
                PASSWORD_TYPED="true"
            else
                echo "LUKS password don't match. Please, type again."
            fi
        done
    fi
}

function partition() {
    # setup
    if [ "$PARTITION_MODE" == "auto" ]; then
        if [ "$BIOS_TYPE" == "uefi" ]; then
            if [ "$DEVICE_SATA" == "true" ]; then
                PARTITION_BOOT="${DEVICE}1"
                PARTITION_ROOT="${DEVICE}2"
                DEVICE_ROOT="${DEVICE}2"
            fi

            if [ "$DEVICE_NVME" == "true" ]; then
                PARTITION_BOOT="${DEVICE}p1"
                PARTITION_ROOT="${DEVICE}p2"
                DEVICE_ROOT="${DEVICE}p2"
            fi

            if [ "$DEVICE_MMC" == "true" ]; then
                PARTITION_BOOT="${DEVICE}p1"
                PARTITION_ROOT="${DEVICE}p2"
                DEVICE_ROOT="${DEVICE}p2"
            fi
        fi

        if [ "$BIOS_TYPE" == "bios" ]; then
            if [ "$DEVICE_SATA" == "true" ]; then
                PARTITION_BOOT="${DEVICE}1"
                PARTITION_ROOT="${DEVICE}2"
                DEVICE_ROOT="${DEVICE}2"
            fi

            if [ "$DEVICE_NVME" == "true" ]; then
                PARTITION_BOOT="${DEVICE}p1"
                PARTITION_ROOT="${DEVICE}p2"
                DEVICE_ROOT="${DEVICE}p2"
            fi

            if [ "$DEVICE_MMC" == "true" ]; then
                PARTITION_BOOT="${DEVICE}p1"
                PARTITION_ROOT="${DEVICE}p2"
                DEVICE_ROOT="${DEVICE}p2"
            fi
        fi
    elif [ "$PARTITION_MODE" == "custom" ]; then
        PARTITION_PARTED_UEFI="$PARTITION_CUSTOM_PARTED_UEFI"
        PARTITION_PARTED_BIOS="$PARTITION_CUSTOM_PARTED_BIOS"
    fi

    if [ "$PARTITION_MODE" == "custom" -o "$PARTITION_MODE" == "manual" ]; then
        PARTITION_BOOT="$PARTITION_CUSTOMMANUAL_BOOT"
        PARTITION_ROOT="$PARTITION_CUSTOMMANUAL_ROOT"
        DEVICE_ROOT="${PARTITION_ROOT}"
    fi

    PARTITION_BOOT_NUMBER="$PARTITION_BOOT"
    PARTITION_ROOT_NUMBER="$PARTITION_ROOT"
    PARTITION_BOOT_NUMBER="${PARTITION_BOOT_NUMBER//\/dev\/sda/}"
    PARTITION_BOOT_NUMBER="${PARTITION_BOOT_NUMBER//\/dev\/nvme0n1p/}"
    PARTITION_BOOT_NUMBER="${PARTITION_BOOT_NUMBER//\/dev\/mmcblk0p/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/sda/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/nvme0n1p/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/mmcblk0p/}"

    # luks and lvm
    if [ -n "$LUKS_PASSWORD" ]; then
        echo -n "$LUKS_PASSWORD" | cryptsetup --key-file=- open $PARTITION_ROOT $LUKS_DEVICE_NAME
        sleep 5
    fi

    if [ -n "$LUKS_PASSWORD" ]; then
        DEVICE_ROOT="/dev/mapper/$LUKS_DEVICE_NAME"
    fi
    if [ "$LVM" == "true" ]; then
        DEVICE_ROOT="/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
    fi

    PARTITION_OPTIONS="defaults"

    if [ "$DEVICE_TRIM" == "true" ]; then
        PARTITION_OPTIONS="$PARTITION_OPTIONS,noatime"
    fi

    # mount
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        mount -o "subvol=root,$PARTITION_OPTIONS,compress=zstd" "$DEVICE_ROOT" /mnt
        mount -o "$PARTITION_OPTIONS" "$PARTITION_BOOT" /mnt/boot
        mount -o "subvol=home,$PARTITION_OPTIONS,compress=zstd" "$DEVICE_ROOT" /mnt/home
        mount -o "subvol=var,$PARTITION_OPTIONS,compress=zstd" "$DEVICE_ROOT" /mnt/var
        mount -o "subvol=snapshots,$PARTITION_OPTIONS,compress=zstd" "$DEVICE_ROOT" /mnt/snapshots
    else
        mount -o "$PARTITION_OPTIONS" $DEVICE_ROOT /mnt
        mount -o "$PARTITION_OPTIONS" $PARTITION_BOOT /mnt/boot
    fi
}

function recovery() {
    arch-chroot /mnt
}

function main() {
    configuration_install
    sanitize_variables
    check_variables
    warning
    init
    facts
    check_facts
    prepare
    partition
    #recovery
}

main

#!/usr/bin/env bash
set -e

# Arch Linux Install Script Packages (alis-packages) устанавливает программное обеспечение
# пакетов.
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
# # nano alis-packages.conf
# # sudo ./alis-packages.sh

# переменные среды
#USER_NAME=""
#USER_PASSWORD=""

# глобальные переменные (без конфигурации, не редактировать)
SYSTEM_INSTALLATION="false"

CONF_FILE="alis-packages.conf"
LOG_FILE="alis-packages.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function configuration_install() {
    source "$CONF_FILE"
}

function sanitize_variables() {
    PACKAGES_PACMAN=$(sanitize_variable "$PACKAGES_PACMAN")
    PACKAGES_FLATPAK=$(sanitize_variable "$PACKAGES_FLATPAK")
    PACKAGES_SDKMAN=$(sanitize_variable "$PACKAGES_SDKMAN")
    PACKAGES_AUR_COMMAND=$(sanitize_variable "$PACKAGES_AUR_COMMAND")
    PACKAGES_AUR=$(sanitize_variable "$PACKAGES_AUR")
    SYSTEMD_UNITS=$(sanitize_variable "$SYSTEMD_UNITS")
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
    check_variables_boolean "PACKAGES_PACMAN_INSTALL" "$PACKAGES_PACMAN_INSTALL"
    check_variables_boolean "PACKAGES_FLATPAK_INSTALL" "$PACKAGES_FLATPAK_INSTALL"
    check_variables_boolean "PACKAGES_SDKMAN_INSTALL" "$PACKAGES_SDKMAN_INSTALL"
    check_variables_boolean "PACKAGES_AUR_INSTALL" "$PACKAGES_AUR_INSTALL"
    check_variables_list "PACKAGES_AUR_COMMAND" "$PACKAGES_AUR_COMMAND" "paru yay aurman" "true"
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

function init() {
    init_log
}

function init_log() {
    if [ "$LOG" == "true" ]; then
        exec > >(tee -a $LOG_FILE)
        exec 2> >(tee -a $LOG_FILE >&2)
    fi
    set -o xtrace
}

function facts() {
    print_step "facts()"

    if [ $(whoami) == "root" ]; then
        SYSTEM_INSTALLATION="true"
    else
        SYSTEM_INSTALLATION="false"
        USER_NAME="$(whoami)"
    fi
}

function checks() {
    print_step "checks()"

    check_variables_value "USER_NAME" "$USER_NAME"

    if [ -n "$PACKAGES_PACMAN" ]; then
        pacman -Si $PACKAGES_PACMAN
    fi

    if [ "$SYSTEM_INSTALLATION" == "false" ]; then
        ask_sudo
    fi
}

function ask_sudo() {
    sudo pwd >> /dev/null
}

function prepare() {
    print_step "prepare()"
}

function packages() {
    print_step "packages()"

    packages_pacman
    packages_flatpak
    packages_sdkman
    packages_aur
}

function packages_pacman() {
    print_step "packages_pacman()"

    if [ "$PACKAGES_PACMAN_INSTALL" == "true" ]; then
        if [ -n "$PACKAGES_PACMAN" ]; then
            pacman_install "$PACKAGES_PACMAN"
        fi
    fi
}

function packages_flatpak() {
    print_step "packages_flatpak()"

    if [ "$PACKAGES_FLATPAK_INSTALL" == "true" ]; then
        pacman_install "flatpak"

        if [ -n "$PACKAGES_FLATPAK" ]; then
            execute_flatpak "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"

            flatpak_install "$PACKAGES_FLATPAK"
        fi
    fi
}

function packages_sdkman() {
    print_step "packages_sdkman()"

    if [ "$PACKAGES_SDKMAN_INSTALL" == "true" ]; then
        pacman_install "zip unzip"
        execute_user "curl -s https://get.sdkman.io | bash"

        if [ -n "$PACKAGES_SDKMAN" ]; then
            execute_user "sed -i 's/sdkman_auto_answer=.*/sdkman_auto_answer=true/g' /home/$USER_NAME/.sdkman/etc/config"
            sdkman_install "$PACKAGES_SDKMAN"
            execute_user "sed -i 's/sdkman_auto_answer=.*/sdkman_auto_answer=false/g' /home/$USER_NAME/.sdkman/etc/config"
        fi
    fi
}

function packages_aur() {
    print_step "packages_aur()"

    if [ "$PACKAGES_AUR_INSTALL" == "true" ]; then
        pacman_install "git"

        case "$PACKAGES_AUR_COMMAND" in
            "aurman" )
                execute_aur "rm -rf /home/$USER_NAME/.alis/aur/$PACKAGES_AUR_COMMAND && mkdir -p /home/$USER_NAME/.alis/aur && cd /home/$USER_NAME/.alis/aur && git clone https://aur.archlinux.org/$PACKAGES_AUR_COMMAND.git && (cd $PACKAGES_AUR_COMMAND && makepkg -si --noconfirm) && rm -rf /home/$USER_NAME/.alis/aur/$PACKAGES_AUR_COMMAND"
                ;;
            "yay" )
                execute_aur "rm -rf /home/$USER_NAME/.alis/aur/$PACKAGES_AUR_COMMAND && mkdir -p /home/$USER_NAME/.alis/aur && cd /home/$USER_NAME/.alis/aur && git clone https://aur.archlinux.org/$PACKAGES_AUR_COMMAND.git && (cd $PACKAGES_AUR_COMMAND && makepkg -si --noconfirm) && rm -rf /home/$USER_NAME/.alis/aur/$PACKAGES_AUR_COMMAND"
                ;;
            "paru" | *)
                execute_aur "rm -rf /home/$USER_NAME/.alis/aur/$PACKAGES_AUR_COMMAND && mkdir -p /home/$USER_NAME/.alis/aur && cd /home/$USER_NAME/.alis/aur && git clone https://aur.archlinux.org/$PACKAGES_AUR_COMMAND.git && (cd $PACKAGES_AUR_COMMAND && makepkg -si --noconfirm) && rm -rf /home/$USER_NAME/.alis/aur/$PACKAGES_AUR_COMMAND"
                ;;
        esac

        if [ -n "$PACKAGES_AUR" ]; then
            aur_install "$PACKAGES_AUR"
        fi
    fi
}

function pacman_install() {
    ERROR="true"
    set +e
    IFS=' ' PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        COMMAND="pacman -Syu --noconfirm --needed ${PACKAGES[@]}"
        execute_sudo "$COMMAND"
        if [ $? == 0 ]; then
            ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        exit
    fi
}

function flatpak_install() {
    OPTIONS=""
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        OPTIONS="--system"
    fi

    ERROR="true"
    set +e
    IFS=' ' PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        COMMAND="flatpak install $OPTIONS -y flathub ${PACKAGES[@]}"
        execute_flatpak "$COMMAND"
        if [ $? == 0 ]; then
            ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        exit
    fi
}

function sdkman_install() {
    ERROR="true"
    set +e
    IFS=' ' PACKAGES=($1)
    for PACKAGE in "${PACKAGES[@]}"
    do
        IFS=':' PACKAGE=($PACKAGE)
        for VARIABLE in {1..5}
        do
            COMMAND="source /home/$USER_NAME/.sdkman/bin/sdkman-init.sh && sdk install ${PACKAGE[@]}"
            execute_user "$COMMAND"
            if [ $? == 0 ]; then
                ERROR="false"
                break
            else
                sleep 10
            fi
        done
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        exit
    fi
}

function aur_install() {
    ERROR="true"
    set +e
    IFS=' ' PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        COMMAND="$PACKAGES_AUR_COMMAND -Syu --noconfirm --needed ${PACKAGES[@]}"
        execute_aur "$COMMAND"
        if [ $? == 0 ]; then
            ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        exit
    fi
}

function systemd_units() {
    IFS=' ' UNITS=($SYSTEMD_UNITS)
    for U in ${UNITS[@]}; do
        ACTION=""
        UNIT=${U}
        if [[ $UNIT == -* ]]; then
            ACTION="disable"
            UNIT=$(echo $UNIT | sed "s/^-//g")
        elif [[ $UNIT == +* ]]; then
            ACTION="enable"
            UNIT=$(echo $UNIT | sed "s/^+//g")
        elif [[ $UNIT =~ ^[a-zA-Z0-9]+ ]]; then
            ACTION="enable"
            UNIT=$UNIT
        fi

        if [ -n "$ACTION" ]; then
            execute_sudo "systemctl $ACTION $UNIT"
        fi
    done
}

function execute_flatpak() {
    COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "$COMMAND"
    else
        bash -c "$COMMAND"
    fi
}

function execute_aur() {
    COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt sed -i 's/^%wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
        arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USER_NAME -s /usr/bin/bash -c \"$COMMAND\""
        arch-chroot /mnt sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers
    else
        bash -c "$COMMAND"
    fi
}

function execute_sudo() {
    COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "$COMMAND"
    else
        bash -c "sudo $COMMAND"
    fi
}

function execute_user() {
    COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "su $USER_NAME -s /usr/bin/bash -c \"$COMMAND\""
    else
        bash -c "$COMMAND"
    fi
}

function end() {
    echo ""
    echo -e "${GREEN}Arch Linux packages installed successfully"'!'"${NC}"
    echo ""
}

function print_step() {
    STEP="$1"
    echo ""
    echo -e "${LIGHT_BLUE}# ${STEP} step${NC}"
    echo ""
}

function execute_step() {
    STEP="$1"
    STEPS="$2"
    if [[ " $STEPS " =~ " $STEP " ]]; then
        eval $STEP
    else
        echo "Skipping $STEP"
    fi
}

function main() {
    ALL_STEPS=("configuration_install" "sanitize_variables" "check_variables" "init" "facts" "checks" "prepare" "packages" "systemd_units" "end")
    STEP="configuration_install"

    if [ -n "$1" ]; then
        STEP="$1"
    fi
    if [ "$STEP" == "steps" ]; then
        echo "Steps: $ALL_STEPS"
        return 0
    fi

    # get step execute from
    FOUND="false"
    STEPS=""
    for S in ${ALL_STEPS[@]}; do
        if [ $FOUND = "true" -o "${STEP}" = "${S}" ]; then
            FOUND="true"
            STEPS="$STEPS $S"
        fi
    done

    execute_step "configuration_install" "${STEPS}"
    execute_step "sanitize_variables" "${STEPS}"
    execute_step "check_variables" "${STEPS}"
    execute_step "init" "${STEPS}"
    execute_step "facts" "${STEPS}"
    execute_step "prepare" "${STEPS}"
    execute_step "packages" "${STEPS}"
    execute_step "systemd_units" "${STEPS}"
    execute_step "end" "${STEPS}"
}

main $@

# alis

![Arch Linux](https://img.shields.io/badge/-ArchLinux-black?logo=arch-linux)
![Bash](https://img.shields.io/badge/sh-bash-black)


Сценарий установки Arch Linux (или alis) устанавливает автоматическую, автоматизированную и настроенную систему Arch Linux.

Это простой сценарий bash, который полностью автоматизирует установку системы Arch Linux после загрузки с исходного установочного носителя Arch Linux. Он содержит те же команды, которые вы вводите и выполняете одну за другой в интерактивном режиме для завершения установки. Единственное, что требуется от пользователя, - это отредактировать файл конфигурации, чтобы выбрать параметры установки и предпочтения от разбиения на разделы до шифрования, загрузчика, файловой системы, языка и раскладки клавиатуры, среды рабочего стола, ядер, пакетов для установки и графических драйверов. Эта автоматизация делает установку простой и быстрой.

Если спустя некоторое время после обновления системы по какой-либо причине система не загружается правильно, также предоставляется сценарий восстановления для входа в режим восстановления, который позволяет откатить пакеты или выполнить любые другие команды для восстановления системы. Также журнал установки можно взять с <a href="https://asciinema.org/">asciinema</a>.

**Предупреждение! Этот сценарий может удалить все разделы постоянного хранилища. Рекомендуется сначала протестировать его на виртуальной машине, например <a href="https://www.virtualbox.org/">VirtualBox</a>.**

Currently these scripts are for me but maybe they are useful for you too.

Следовать [Arch Way](https://wiki.archlinux.org/index.php/Arch_Linux) делать что-то и узнать, что делает этот скрипт. Это позволит вам узнать, что происходит.

Пожалуйста, не просите поддержки для этого скрипта на форумах Arch Linux, сначала прочтите [Arch Linux wiki](https://wiki.archlinux.org), [Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) и [General Recommendations](https://wiki.archlinux.org/index.php/General_recommendations), позже сравните эти команды с командами этого скрипта.

Чтобы узнать о новых функциях, улучшениях и ошибках, заполните проблему в GitHub или сделайте запрос на перенос. Вы можете проверить это в [VirtualBox](https://www.virtualbox.org/) виртуальную машину (настоятельно рекомендуется), прежде чем запускать ее на реальном оборудовании. Если вы протестируете его на реальном оборудовании, отправьте мне письмо по адресу mr.geek1@protonmail.com с описанием машины и сообщите, если что-то пойдет не так или все работает нормально. [Pull request](https://github.com/mrgeek12/alis/pulls) и [new feature request](https://github.com/mrgeek12/alis/issues) добро пожаловать!

** Сценарий установки Arch Linux (alis) основан на Arch Linux, но НЕ одобрен, не спонсируется и не связан с Arch Linux или связанными с ним проектами. **

[![Arch Linux](https://mrgeek12.github.io/alis/images/logos/archlinux.svg "Arch Linux")](https://www.archlinux.org/)

### Index

* [Принципы](https://github.com/mrgeek12/alis#principles)
* [Функции](https://github.com/mrgeek12/alis#features)
* [Установка системы](https://github.com/mrgeek12/alis#system-installation)
* [Установка пакетов](https://github.com/mrgeek12/alis#packages-installation)
* [Восстановление](https://github.com/mrgeek12/alis#recovery)
* [Как ты можешь помочь](https://github.com/mrgeek12alis#how-you-can-help)
* [Тест в VirtualBox с Packer](https://github.com/mrgeek12/alis#test-in-virtualbox-with-packer)
* [Видео](https://github.com/picodotdev/alis#video)
* [Установочный носитель Arch Linux](https://github.com/mrgeek12/alis#arch-linux-installation-media)
* [Ссылки](https://github.com/mrgeek12/alis#reference)

### Принципы

* Используйте оригинальный установочный носитель Arch Linux.
* Максимально автоматизированный и автоматизированный, требует как можно меньше интерактивности
* Позволяет настроить установку для наиболее распространенных случаев
* Обеспечить поддержку восстановления системы
* Обеспечение поддержки журнала установки

### Функции

* ** Система **: UEFI, BIOS
* ** Хранилище **: SATA, NVMe и MMC
* ** Шифрование **: корневой раздел зашифрован и не зашифрован
* ** Раздел **: нет LVM, LVM, LVM в LUKS, GPT в UEFI, MBR в BIOS
* ** Файловая система **: ext4, btrfs (с вложенными томами), xfs, f2fs, reiserfs
* ** Ядра **: linux, linux-lts, linux-hardened, linux-zen
* ** Среда рабочего стола **: GNOME, KDE, XFCE, Mate, Cinnamon, LXDE, i3-wm, i3-gaps, Deepin
* ** Диспетчеры **: GDM, SDDM, Lightdm, lxdm
* ** Графический контроллер **: Intel, NVIDIA и AMD с возможностью раннего запуска KMS. С Intel опционально fastboot, аппаратным ускорением видео и сжатием кадрового буфера.
* ** Загрузчик **: GRUB, rEFInd, systemd-boot
* ** Пользовательская оболочка **: bash, zsh, dash, fish
* ** Установка сети WPA WIFI **
* ** Periodic TRIM ** для SSD-накопителя
* Микрокод процессоров Intel и AMD ** **
* Необязательный ** файл подкачки **
* ** гостевые дополнения VirtualBox **
* ** Сжатие ядра ** и ** специальные параметры **
* ** Создание пользователей ** и ** добавление в sudoers **
* ** systemd units включить или отключить **
* ** Поддержка Multilib **
* ** Arch Linux ** установка обычных и пользовательских ** пакетов **
* Установка утилиты Flatpak и ** установка пакетов Flatpak **
* Установка утилиты SDKMAN и ** установка пакетов SDKMAN **
* Установка ** утилиты AUR ** (paru, yay, aurman) и ** установка пакетов AUR **
* ** Установка пакетов после установки базовой системы ** (предпочтительный способ установки пакетов)
* Скрипт для загрузки, установки и ** скрипты восстановления ** и файлы конфигурации
* ** Повторить загрузку пакетов ** при ошибке подключения / зеркала
* ** Поддержка упаковщика ** для тестирования в VirtualBox
* ** Журнал установки ** со всеми выполненными командами и выводом в файл и / или ** asciinema video **
* После установки дождитесь ** прерывистой перезагрузки **
* Разветвите репозиторий и ** используйте свою собственную конфигурацию **

### Установка системы

Загрузите и загрузитесь с последней <a href="https://www.archlinux.org/download/">оригинальный установочный носитель Arch Linux</a>. После загрузки используйте следующие команды, чтобы начать установку.

Следовать <a href="https://wiki.archlinux.org/index.php/Arch_Linux">Arch Way</a> делать что-то и узнать, что делает этот скрипт. Это позволит вам узнать, что происходит.

Требуется подключение к Интернету, с беспроводным подключением WIFI см. <a href="https://wiki.archlinux.org/index.php/Wireless_network_configuration#Wi-Fi_Protected_Access">Wireless_network_configuration</a> для подключения WIFI перед началом установки.

```
#                         # Start the system with latest Arch Linux installation media
# loadkeys [keymap]       # Load keyboard keymap, eg. loadkeys es, loadkeys us, loadkeys de
# iwctl --passphrase "[WIFI_KEY]" station [WIFI_INTERFACE] connect "[WIFI_ESSID]"          # (Optional) Connect to WIFI network. _ip link show_ to know WIFI_INTERFACE.
# curl -sL https://raw.githubusercontent.com/mrgeek12/alis/master/download.sh | bash     # Download alis scripts
# # curl -sL https://bit.ly/2F3CATp | bash                                                 # Alternative download URL with URL shortener
# ./alis-asciinema.sh     # (Optional) Start asciinema video recording
# vim alis.conf           # Edit configuration and change variables values with your preferences (system configuration)
# vim alis-packages.conf  # (Optional) Edit configuration and change variables values with your preferences (packages to install)
#                         # (The preferred way to install packages is after system installation, see Packages installation)
# ./alis.sh               # Start installation
# ./alis-reboot.sh        # (Optional) Reboot the system, only necessary when REBOOT="false"
```

Если вы разветвляете репозиторий _alis_, вы можете разместить свою собственную конфигурацию и изменения в своем репозитории.

```
# curl https://raw.githubusercontent.com/mrgeek12/alis/master/download.sh | bash -s -- -u [github user]
```

### Установка пакетов

После установки базовой системы Arch Linux alis может устанавливать пакеты с помощью pacman, Flatpak, SDKMAN и из AUR.

```
#                                  # After system installation start a user session
# curl -sL https://raw.githubusercontent.com/mrgeek12/alis/master/download.sh | bash     # Download alis scripts
# # curl -sL https://bit.ly/3b0TtAh | bash                                                 # Alternative download URL with URL shortener
# ./alis-packages-asciinema.sh     # (Optional) Start asciinema video recording
# vim alis-packages.conf           # Edit configuration and change variables values with your preferences (packages to install)
# ./alis-packages.sh               # Start packages installation
```

### Восстановление

Загрузиться с последней <a href="https://www.archlinux.org/download/">оригинальный установочный носитель Arch Linux</a>. После загрузки используйте следующие команды для запуска восстановления, это позволит вам войти в среду arch-chroot.

```
#                                  # Start the system with latest Arch Linux installation media
# loadkeys [keymap]                # Load keyboard keymap, eg. loadkeys es, loadkeys us, loadkeys de
# iwctl --passphrase "[WIFI_KEY]" station [WIFI_INTERFACE] connect "[WIFI_ESSID]"          # (Optional) Connect to WIFI network. _ip link show_ to know WIFI_INTERFACE.
# curl -sL https://raw.githubusercontent.com/mrgeek12/alis/master/download.sh | bash     # Download alis scripts
# # curl -sL https://bit.ly/3b0TtAh | bash                                                 # Alternative download URL with URL shortener
# ./alis-recovery-asciinema.sh     # (Optional) Start asciinema video recording
# vim alis-recovery.conf           # Edit configuration and change variables values with your last installation configuration with alis (mainly device and partition scheme)
# ./alis-recovery.sh               # Start recovery
# ./alis-recovery-reboot.sh        # Reboot the system
```

### Как ты можешь помочь

* Протестируйте в VirtualBox и создайте проблему, если что-то не работает, прикрепите основные части используемого файла конфигурации и сообщение об ошибке
* Создавать проблемы с новыми функциями
* Отправить запросы на вытягивание
* Поделитесь им в социальных сетях, на форумах, создайте пост в блоге или видео об этом
* Напишите мне письмо, я люблю читать, что скрипт уже используется и полезен :). Каковы характеристики вашего компьютера, какова ваша конфигурация alis, ваш персональный или рабочий компьютер, все ли работает нормально или какие-то предложения по улучшению скрипта

### Тест в VirtualBox с Packer

VirtualBox и [Packer](https://packer.io/) являются обязательными.

* Прошивка: efi, bios
* Файловая система: ext4, btrfs, f2fs, xfs
* Раздел: luks, lvm
* Загрузчик: grub, refind, systemd
* Окружение рабочего стола: gnome, kde, xfce, ...

```
$ ./alis-packer.sh -c alis-packer-efi-ext4-systemd.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-systemd-gnome.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-luks-lvm-grub.sh
$ ./alis-packer.sh -c alis-packer-efi-btrfs-luks-lvm-systemd.sh
$ ./alis-packer.sh -c alis-packer-efi-f2fs-luks-lvm-systemd.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-grub-gnome.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-grub-kde.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-grub-xfce.sh
```

### Видео

[![asciicast](https://asciinema.org/a/418524.png)](https://asciinema.org/a/418524)

### Установочный носитель Arch Linux

https://www.archlinux.org/download/

### Ссылки

* https://wiki.archlinux.org/index.php/Installation_guide
* https://wiki.archlinux.org/index.php/Main_page
* https://wiki.archlinux.org/index.php/General_recommendations
* https://wiki.archlinux.org/index.php/List_of_applications
* https://wiki.archlinux.org/index.php/Intel_NUC
* https://wiki.archlinux.org/index.php/Network_configuration
* https://wiki.archlinux.org/index.php/Wireless_network_configuration
* https://wiki.archlinux.org/index.php/Wireless_network_configuration#Connect_to_an_access_point
* https://wiki.archlinux.org/index.php/NetworkManager
* https://wiki.archlinux.org/index.php/Solid_State_Drives
* https://wiki.archlinux.org/index.php/Solid_state_drive/NVMe
* https://wiki.archlinux.org/index.php/Partitioning
* https://wiki.archlinux.org/index.php/Fstab
* https://wiki.archlinux.org/index.php/Swap
* https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface
* https://wiki.archlinux.org/index.php/EFI_System_Partition
* https://wiki.archlinux.org/index.php/File_systems
* https://wiki.archlinux.org/index.php/Ext4
* https://wiki.archlinux.org/index.php/Btrfs
* https://wiki.archlinux.org/index.php/XFS
* https://wiki.archlinux.org/index.php/F2FS
* https://wiki.archlinux.org/index.php/Persistent_block_device_naming
* https://wiki.archlinux.org/index.php/LVM
* https://wiki.archlinux.org/index.php/Dm-crypt
* https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption
* https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system
* https://wiki.archlinux.org/index.php/Pacman
* https://wiki.archlinux.org/index.php/Arch_User_Repository
* https://wiki.archlinux.org/index.php/Mirrors
* https://wiki.archlinux.org/index.php/Reflector
* https://wiki.archlinux.org/index.php/VirtualBox
* https://wiki.archlinux.org/index.php/Mkinitcpio
* https://wiki.archlinux.org/index.php/Intel_graphics
* https://wiki.archlinux.org/index.php/AMDGPU
* https://wiki.archlinux.org/index.php/ATI
* https://wiki.archlinux.org/index.php/NVIDIA
* https://wiki.archlinux.org/index.php/Nouveau
* https://wiki.archlinux.org/index.php/Kernels
* https://wiki.archlinux.org/index.php/Kernel_mode_setting
* https://wiki.archlinux.org/index.php/Kernel_parameters
* https://wiki.archlinux.org/index.php/Category:Boot_loaders
* https://wiki.archlinux.org/index.php/GRUB
* https://wiki.archlinux.org/index.php/REFInd
* https://wiki.archlinux.org/index.php/Systemd-boot
* https://wiki.archlinux.org/index.php/Systemd
* https://wiki.archlinux.org/index.php/Microcode
* https://wiki.archlinux.org/index.php/Command-line_shell
* https://wiki.archlinux.org/index.php/Wayland
* https://wiki.archlinux.org/index.php/Xorg
* https://wiki.archlinux.org/index.php/Desktop_environment
* https://wiki.archlinux.org/index.php/GNOME
* https://wiki.archlinux.org/index.php/KDE
* https://wiki.archlinux.org/index.php/Xfce
* https://wiki.archlinux.org/index.php/I3
* https://wiki.archlinux.org/title/Deepin_Desktop_Environment
* http://tldp.org/LDP/Bash-Beginners-Guide/html/
* http://tldp.org/LDP/abs/html/

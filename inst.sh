#!/bin/bash
clear
echo -e "label: gpt\ndevice: /dev/nvme0n1\n\n/dev/nvme0n1p1 : start=2048, size=1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B\n/dev/nvme0n1p2 : start=1050624, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4" | sfdisk -fw always /dev/nvme0n1 && sleep 0.5s
echo -e "label: gpt\ndevice: /dev/sda\n\n/dev/sda1 : start=2048, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4" | sfdisk -fw always /dev/sda && sleep 1s

mkfs.vfat -F 32 /dev/nvme0n1p1 && sleep 0.5s
mkfs.xfs /dev/nvme0n1p2 && sleep 0.5s
mkfs.xfs /dev/sda1 && sleep 1s

mount /dev/nvme0n1p2 /mnt && sleep 0.5s
mkdir -p /mnt/boot && sleep 0.5s
mount /dev/nvme0n1p1 /mnt/boot && sleep 1s

basestrap /mnt 7zip acpid-dinit amd-ucode base blueman bluez-dinit chrony-dinit connman-dinit connman-gtk dbus-dinit dbus-dinit-user dinit dosfstools efibootmgr exfatprogs fastfetch ffmpeg ffmpegthumbnailer geany gimp gnu-free-fonts gsfonts lact-dinit linux-firmware-amdgpu linux-firmware-other linux-firmware-realtek linux-firmware-xz linux-rt mesa metalog-dinit mpv nano nwg-look opendoas pavucontrol-qt pipewire-audio pipewire-dinit pipewire-jack pipewire-pulse-dinit prismlauncher python-adblock qt6gtk2 qt6-multimedia-ffmpeg qutebrowser ristretto seatd-dinit shotcut thunar thunar-archive-plugin tumbler turnstile-dinit vulkan-mesa-layers vulkan-radeon wireplumber-dinit xarchiver xdg-desktop-portal-gtk xdg-user-dirs xdg-utils xfce4-eyes-plugin xfce4-notifyd xfce4-panel xfce4-pulseaudio-plugin xfce4-screensaver xfce4-screenshooter xfce4-sensors-plugin xfce4-taskmanager xfce4-terminal xfdesktop xfsprogs xfwm4 xlibre-input-libinput xlibre-video-amdgpu xlibre-xserver xorg-xinit yt-dlp zramen-dinit && sleep 1s

echo -e "/dev/nvme0n1p1 /boot vfat umask=0077,tz=UTC 0 2\n/dev/nvme0n1p2 / xfs defaults,noatime 0 1\n/dev/sda1 /mnt/hdd xfs defaults,noatime,nofail 0 2" > /mnt/etc/fstab && sleep 1s

artix-chroot /mnt && sleep 1s

mkdir -p /mnt/hdd && sleep 0.5s
mkdir -p /mnt/usb1 && sleep 0.5s
mkdir -p /mnt/usb2 && sleep 0.5s
mkdir -p /mnt/usb3 && sleep 1s

echo -e "[options]\nHookDir = /etc/pacman.d/hooks/\nHoldPkg = pacman glibc\nArchitecture = auto\nIgnorePkg = elogind lib32-elogind lib32-polkit polkit sudo\nColor\nCheckSpace\nVerbosePkgLists\nParallelDownloads = 16\nDownloadUser = alpm\nSigLevel = Required DatabaseOptional\n[system]\nInclude = /etc/pacman.d/mirrorlist\n[world]\nInclude = /etc/pacman.d/mirrorlist\n[galaxy]\nInclude = /etc/pacman.d/mirrorlist\n[lib32]\nInclude = /etc/pacman.d/mirrorlist" > /etc/pacman.conf && sleep 1s

mkdir -p /etc/pacman.d/hooks
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Cleaning package cache...\nWhen = PostTransaction\nExec = /usr/bin/pacman -Sc" > /etc/pacman.d/hooks/cache.hook && sleep 0.5s
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Running fstrim on all mounted filesystems...\nWhen = PostTransaction\nExec = /usr/bin/fstrim -a" > /etc/pacman.d/hooks/disks.hook && sleep 0.5s
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Checking for orphaned packages...\nWhen = PostTransaction\nExec = /usr/bin/pacman -Qdtt" > /etc/pacman.d/hooks/orphans.hook && sleep 1s

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && sleep 0.5s
echo -e "C.UTF-8 UTF-8" > /etc/locale.gen && sleep 0.5s
locale-gen && sleep 0.5s
echo -e "LANG=C.UTF-8" > /etc/locale.conf && sleep 1s

efibootmgr -c -d /dev/nvme0n1 -l /vmlinuz-linux-rt -L "Artix Linux" -p 1 -u 'amdgpu.ppfeaturemask=0xffffffff clocksource=tsc initrd=\initramfs-linux-rt.img loglevel=4 mitigations=off nmi_watchdog=0 nosoftlockup root=/dev/nvme0n1p2 rw sysctl.fs.file-max=10485760 sysctl.vm.max_map_count=1048576 sysctl.vm.swappiness=10 tsc=reliable' && sleep 1s

useradd -G audio,disk,input,network,power,seat,storage,tty,users,video,wheel -m adamina && sleep 1s

echo -e "permit keepenv persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel\npermit nopass :wheel as root cmd /usr/bin/shutdown" > /etc/doas.conf && sleep 1s

echo -e "antartix" > /etc/hostname && sleep 0.5s
echo -e "127.0.0.1 localhost\n::1 localhost" > /etc/hosts && sleep 0.5s
echo -e "[General]\nAllowHostnameUpdates=false\nPreferredTechnologies=ethernet,wifi" > /etc/connman/main.conf && sleep 1s

echo -e "EDITOR=nano\nLD_BIND_NOW=1\nQT_QPA_PLATFORMTHEME=gtk2" > /etc/environment && sleep 1s

echo -e 'ACTIVE_CONSOLES="/dev/tty1"' > /etc/dinit.d/config/console.conf && sleep 0.5s
echo -e 'GETTY_ARGS="-a adamina -J"\nGETTY_BAUD=38400\nGETTY_TERM=linux' > /etc/dinit.d/config/agetty-tty1.conf && sleep 1s

echo -e "debug = no\nbackend = dinit\ndebug_stderr = no\nlinger = no\nrundir_path = /run/user/%u\nmanage_rundir = yes\nexport_dbus_address = yes\nlogin_timeout = 60\nroot_session = no" > /etc/turnstile/turnstiled.conf && sleep 1s

echo -e 'MODULES=(nct6683 ntsync)\nBINARIES=()\nFILES=()\nHOOKS=(base udev autodetect microcode modconf kms keyboard keymap block filesystems fsck)\nCOMPRESSION="zstd"\nCOMPRESSION_OPTIONS=()\nMODULES_DECOMPRESS="no"' > /etc/mkinitcpio.conf && sleep 0.5s
mkinitcpio -P && sleep 1s

echo -e "ZRAM_COMP_ALGORITHM=zstd\nZRAM_MAX_SIZE=8192\nZRAM_PRIORITY=32767\nZRAM_SIZE=32\nZRAMEN_QUIET=1\nZRAMEN_SWAPON_DISCARD=true" > /etc/dinit.d/config/zramen.conf && sleep 1s

echo -e "adamina hard nofile 1048576\nadamina soft nofile 1048576" > /etc/security/limits.conf && sleep 1s

ln -s /etc/dinit.d/acpid /etc/dinit.d/boot.d/acpid && sleep 0.5s
ln -s /etc/dinit.d/bluetoothd /etc/dinit.d/boot.d/bluetoothd && sleep 0.5s
ln -s /etc/dinit.d/chrony /etc/dinit.d/boot.d/chrony && sleep 0.5s
ln -s /etc/dinit.d/connmand /etc/dinit.d/boot.d/connmand && sleep 0.5s
ln -s /etc/dinit.d/dbus /etc/dinit.d/boot.d/dbus && sleep 0.5s
ln -s /etc/dinit.d/lact /etc/dinit.d/boot.d/lact && sleep 0.5s
ln -s /etc/dinit.d/metalog /etc/dinit.d/boot.d/metalog && sleep 0.5s
ln -s /etc/dinit.d/seatd /etc/dinit.d/boot.d/seatd && sleep 0.5s
ln -s /etc/dinit.d/turnstiled /etc/dinit.d/boot.d/turnstiled && sleep 0.5s
ln -s /etc/dinit.d/zramen /etc/dinit.d/boot.d/zramen && sleep 0.5s
su adamina -c 'mkdir -p /home/adamina/.config/dinit.d/boot.d' && sleep 0.5s
ln -s /etc/dinit.d/user/dbus /home/adamina/.config/dinit.d/boot.d/dbus && sleep 0.5s
ln -s /etc/dinit.d/user/pipewire /home/adamina/.config/dinit.d/boot.d/pipewire && sleep 0.5s
ln -s /etc/dinit.d/user/pipewire-pulse /home/adamina/.config/dinit.d/boot.d/pipewire-pulse && sleep 0.5s
ln -s /etc/dinit.d/user/wireplumber /home/adamina/.config/dinit.d/boot.d/wireplumber && sleep 1s

pacman -Syu && sleep 0.5s
pacman -S --noconfirm lib32-mesa lib32-vulkan-mesa-layers lib32-vulkan-radeon steam --assume-installed lib32-elogind && sleep 0.5s
pacman -S --noconfirm mugshot xfce4-weather-plugin xfce4-whiskermenu-plugin --assume-installed polkit && sleep 1s

su adamina -c 'mkdir -p /home/adamina/.local/share/ALVR-Launcher/installations/Nightly' && sleep 0.5s
su adamina -c 'curl -sL https://github.com/alvr-org/ALVR/releases/latest/download/alvr_launcher_linux.tar.gz -o /home/adamina/.local/share/ALVR-Launcher/alvr.tar.gz' && sleep 0.5s
su adamina -c 'tar -xzf /home/adamina/.local/share/ALVR-Launcher/alvr.tar.gz -C /home/adamina/.local/share/ALVR-Launcher' && sleep 0.5s
su adamina -c 'mv "/home/adamina/.local/share/ALVR-Launcher/alvr_launcher_linux/ALVR Launcher" /home/adamina/.local/share/ALVR-Launcher/ALVR' && sleep 0.5s
su adamina -c 'rm /home/adamina/.local/share/ALVR-Launcher/alvr.tar.gz' && sleep 0.5s
su adamina -c 'rm -r /home/adamina/.local/share/ALVR-Launcher/alvr_launcher_linux' && sleep 1s

su adamina -c 'curl -sL https://github.com/alvr-org/ALVR-nightly/releases/latest/download/alvr_streamer_linux.tar.gz -o /home/adamina/.local/share/ALVR-Launcher/alvrNightly.tar.gz' && sleep 0.5s
su adamina -c 'tar -xzf /home/adamina/.local/share/ALVR-Launcher/alvrNightly.tar.gz -C /home/adamina/.local/share/ALVR-Launcher/installations/Nightly' && sleep 0.5s
su adamina -c 'rm /home/adamina/.local/share/ALVR-Launcher/alvrNightly.tar.gz' && sleep 1s

echo -e '#!/bin/bash\nrepo=$(curl -sL https://github.com/SpookySkeletons?tab=repositories | grep -iom 1 "proton.\+rtsp")\nrtspVer=$(curl -sL https://github.com/SpookySkeletons/$repo/releases/latest | grep -iom 1 "proton.\+spo" | sed "s/......$//")\ninstRTSP=$(ls /home/adamina/.local/share/Steam/compatibilitytools.d | grep -iom 1 "proton.\+")\nnotify-send -u critical -i steam "RTSP Proton Updater" "Latest: ${rtspVer,,}\\nInstalled: $instRTSP"\n/home/adamina/.local/share/ALVR-Launcher/ALVR' > /usr/local/bin/alvr && sleep 0.5s
chmod +x /usr/local/bin/alvr && sleep 1s

mkdir -p /usr/local/share/applications && sleep 0.5s
echo -e "[Desktop Entry]\nType=Application\nName=ALVR\nComment=Stream VR games from your PC to your headset via Wi-Fi\nExec=/usr/local/bin/alvr\nIcon=applications-engineering\nCategories=Game" > /usr/local/share/applications/alvr.desktop && sleep 1s

su adamina -c 'mkdir -p /home/adamina/.local/share/Steam/compatibilitytools.d' && sleep 0.5s
su adamina -c 'curl -sL https://github.com/SpookySkeletons/$(curl -sL https://github.com/SpookySkeletons?tab=repositories | grep -iom 1 "proton.\+rtsp")/releases/download/proton-rtsp-11.0-20260609-1/proton-rtsp-11.0-20260609-1.tar.gz -o /home/adamina/.local/share/Steam/compatibilitytools.d/rtsp.tar.gz' && sleep 0.5s
su adamina -c 'tar -xzf /home/adamina/.local/share/Steam/compatibilitytools.d/rtsp.tar.gz -C /home/adamina/.local/share/Steam/compatibilitytools.d' && sleep 0.5s
su adamina -c 'rm /home/adamina/.local/share/Steam/compatibilitytools.d/rtsp.tar.gz' && sleep 1s

su adamina -c 'xdg-user-dirs-update' && sleep 0.5s
su adamina -c 'mkdir -p /home/adamina/.icons' && sleep 0.5s
su adamina -c 'mkdir -p /home/adamina/.themes' && sleep 0.5s
su adamina -c 'mkdir -p /home/adamina/Pictures/Screenshots' && sleep 0.5s
su adamina -c 'mkdir -p /home/adamina/Pictures/Wallpapers' && sleep 1s

su adamina -c 'echo -e "xrandr --output DisplayPort-1 --mode 2560x1440 --rate 120.00 --set TearFree on --set \"max bpc\" 10 --set \"Broadcast RGB\" Full &\nxrandr --output DisplayPort-2 --mode 2560x1440 --rate 120.00 --set TearFree on --set \"max bpc\" 10 --set \"Broadcast RGB\" Full &\n/usr/lib/xfce4/notifyd/xfce4-notifyd &\nxfce4-panel &\nxfce4-screensaver &\nxfdesktop &\nblueman-applet &\nconnman-gtk --tray &\nsteam -silent steam://unlockh264/ &\nthunar --daemon &\nexec xfwm4" > /home/adamina/.xinitrc' && sleep 0.5s
su adamina -c 'echo -e "[[ -f ~/.bashrc ]] && . ~/.bashrc\nstartx" > /home/adamina/.bash_profile' && sleep 1s

su adamina -c 'cp /usr/share/applications/org.qutebrowser.qutebrowser.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/steam.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/local/share/applications/alvr.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/org.prismlauncher.PrismLauncher.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/gimp.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/xfce4-terminal.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/geany.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/mpv.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/io.github.ilya_zlobintsev.LACT.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/org.shotcut.Shotcut.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/xfce4-taskmanager.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'cp /usr/share/applications/xfce4-sensors.desktop /home/adamina/Desktop' && sleep 0.5s
su adamina -c 'echo -e "Whisker menu:\nThe whisker menu provides the ability to remap buttons unlike the stock menu.\nThis is particularly useful for GTK settings and shutting down and rebooting.\nAfter adding the whisker menu to the panel, set the following commands in the properties menu:\n  - Settings Manager: nwg-look\n  - Restart: doas /usr/bin/shutdown -r\n  - Shut Down: doas /usr/bin/shutdown\n  - Edit Profile: mugshot\n\nSteam:\nBizarrely, Steam does not automatically unlock the H264 decoder by default.\nThis decoder is required for RTSP Proton and other Steam functions to work correctly.\nTo enable it, sign into Steam normally first, then restart the computer or exit Steam and run:\n  - steam steam://unlockh264/\nAfter running it, wait for Steam to open normally and wait about 1-2 minutes, then exit Steam and start it normally.\nIf codec issues arise again later, try running this again after a Steam or RTSP Proton update.\n\nSteam Autostart:\nSteam is configured to automatically start with the system in the background.\nJust start Steam once normally to configure the runtime and it will start automatically on every boot after." > /home/adamina/Desktop/README.txt' && sleep 1s

su adamina -c 'chmod +x /home/adamina/Desktop/*' && sleep 1s

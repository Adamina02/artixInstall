#!/bin/bash
echo -e "label: gpt\ndevice: /dev/vda\n\n/dev/vda1 : start=2048, size=1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B\n/dev/vda2 : start=1050624, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4" | sfdisk /dev/vda && sleep 1s

mkfs.vfat -F 32 /dev/vda1 && sleep 0.5s
mkfs.xfs /dev/vda2 && sleep 1s

mount /dev/vda2 /mnt && sleep 0.5s
mkdir -p /mnt/boot && sleep 0.5s
mount /dev/vda1 /mnt/boot && sleep 1s

basestrap /mnt 7zip acpid-dinit amd-ucode base blueman bluez-dinit chrony-dinit connman-dinit connman-gtk dbus-dinit dbus-dinit-user dinit dosfstools efibootmgr fastfetch ffmpeg ffmpegthumbnailer gimp gnu-free-fonts gsfonts iwd lact-dinit linux-firmware-amdgpu linux-firmware-intel linux-firmware-other linux-firmware-realtek linux-firmware-xz linux-rt mesa metalog-dinit mousepad mpv nano nwg-look opendoas pavucontrol-qt pipewire-audio pipewire-dinit pipewire-jack pipewire-pulse-dinit prismlauncher python-adblock qt6gtk2 qt6-multimedia-ffmpeg qutebrowser ristretto seatd-dinit shotcut thunar thunar-archive-plugin tumbler turnstile-dinit vulkan-mesa-layers vulkan-radeon wireplumber-dinit xarchiver xdg-desktop-portal-gtk xdg-user-dirs xdg-utils xfce4-panel xfce4-pulseaudio-plugin xfce4-screensaver xfce4-screenshooter xfce4-taskmanager xfce4-terminal xfdesktop xfsprogs xfwm4 xlibre-input-libinput xlibre-video-amdgpu xlibre-xserver xorg-xinit yt-dlp zramen-dinit && sleep 1s

echo -e "/dev/vda1 /boot vfat umask=0077,tz=UTC 0 2\n/dev/vda2 / xfs defaults,noatime 0 1" > /mnt/etc/fstab && sleep 1s

artix-chroot /mnt && sleep 1s

echo -e "[options]\nHookDir = /etc/pacman.d/hooks/\nHoldPkg = pacman glibc\nArchitecture = auto\nIgnorePkg = elogind lib32-elogind lib32-polkit polkit sudo\nColor\nCheckSpace\nVerbosePkgLists\nParallelDownloads = 16\nDownloadUser = alpm\nSigLevel = Required DatabaseOptional\n[system]\nInclude = /etc/pacman.d/mirrorlist\n[world]\nInclude = /etc/pacman.d/mirrorlist\n[galaxy]\nInclude = /etc/pacman.d/mirrorlist\n[lib32]\nInclude = /etc/pacman.d/mirrorlist" > /etc/pacman.conf && sleep 1s

echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Cleaning package cache...\nWhen = PostTransaction\nExec = /usr/bin/pacman -Sc" > /etc/pacman.d/hooks/cache.hook && sleep 0.5s
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Running fstrim on all mounted filesystems...\nWhen = PostTransaction\nExec = /usr/bin/fstrim -a" > /etc/pacman.d/hooks/disks.hook && sleep 0.5s
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Checking for orphaned packages...\nWhen = PostTransaction\nExec = /usr/bin/pacman -Qdtt" > /etc/pacman.d/hooks/orphans.hook && sleep 1s

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && sleep 0.5s
echo -e "C.UTF-8 UTF-8" > /etc/locale.gen && sleep 0.5s
locale-gen && sleep 0.5s
echo -e "LANG=C.UTF-8" > /etc/locale.conf && sleep 1s

efibootmgr -c -d /dev/vda -l /vmlinuz-linux-rt -L "Artix Linux" -p 1 -u 'amdgpu.ppfeaturemask=0xffffffff clocksource=tsc initrd=\initramfs-linux-rt.img loglevel=4 mitigations=off root=/dev/vda2 rw sysctl.fs.file-max=10485760 sysctl.vm.max_map_count=1048576 sysctl.vm.swappiness=10 tsc=reliable' && sleep 1s

useradd -G audio,disk,input,network,power,seat,storage,tty,users,video,wheel -m vmuser && sleep 1s

echo -e "permit keepenv persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel" > /etc/doas.conf && sleep 1s

echo -e "antartix" > /etc/hostname && sleep 0.5s
echo -e "127.0.0.1 localhost\n::1 localhost" > /etc/hosts && sleep 0.5s
echo -e "[General]\nAllowHostnameUpdates=false\nPreferredTechnologies=ethernet,wifi" > /etc/connman/main.conf && sleep 1s

echo -e "EDITOR=nano\nLD_BIND_NOW=1\nQT_QPA_PLATFORMTHEME=gtk2" > /etc/environment && sleep 1s

echo -e 'ACTIVE_CONSOLES="/dev/tty1"' > /etc/dinit.d/config/console.conf && sleep 0.5s
echo -e 'GETTY_ARGS="-a vmuser -J"\nGETTY_BAUD=38400\nGETTY_TERM=linux' > /etc/dinit.d/config/agetty-tty1.conf && sleep 1s

echo -e "debug = no\nbackend = dinit\ndebug_stderr = no\nlinger = no\nrundir_path = /run/user/%u\nmanage_rundir = yes\nexport_dbus_address = yes\nlogin_timeout = 60\nroot_session = no" > /etc/turnstile/turnstiled.conf && sleep 1s

echo -e 'MODULES=(nct6683 ntsync)\nBINARIES=()\nFILES=()\nHOOKS=(base udev autodetect microcode modconf kms keyboard keymap block filesystems fsck)\nCOMPRESSION="zstd"\nCOMPRESSION_OPTIONS=()\nMODULES_DECOMPRESS="no"' > /etc/mkinitcpio.conf && sleep 0.5s
mkinitcpio -P && sleep 1s

echo -e "ZRAM_COMP_ALGORITHM=zstd\nZRAM_MAX_SIZE=8192\nZRAM_PRIORITY=32767\nZRAM_SIZE=32\nZRAMEN_QUIET=1\nZRAMEN_SWAPON_DISCARD=true" > /etc/dinit.d/config/zramen.conf && sleep 1s

echo -e "vmuser hard nofile 1048576\nvmuser soft nofile 1048576" > /etc/security/limits.conf && sleep 1s

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
su vmuser -c "mkdir -p /home/vmuser/.config/dinit.d/boot.d" && sleep 0.5s
ln -s /etc/dinit.d/user/dbus /home/vmuser/.config/dinit.d/boot.d/dbus && sleep 0.5s
ln -s /etc/dinit.d/user/pipewire /home/vmuser/.config/dinit.d/boot.d/pipewire && sleep 0.5s
ln -s /etc/dinit.d/user/pipewire-pulse /home/vmuser/.config/dinit.d/boot.d/pipewire-pulse && sleep 0.5s
ln -s /etc/dinit.d/user/wireplumber /home/vmuser/.config/dinit.d/boot.d/wireplumber && sleep 1s

pacman -Syu && sleep 0.5s
pacman -S --noconfirm lib32-mesa lib32-vulkan-mesa-layers lib32-vulkan-radeon steam --assume-installed lib32-elogind && sleep 0.5s
pacman -S --noconfirm mugshot xfce4-whiskermenu-plugin --assume-installed polkit && sleep 1s

su vmuser -c 'mkdir -p /home/vmuser/.local/share/ALVR-Launcher/installations/Nightly' && sleep 0.5s
su vmuser -c 'curl -sL https://github.com/alvr-org/ALVR/releases/latest/download/alvr_launcher_linux.tar.gz -o /home/vmuser/.local/share/ALVR-Launcher/alvr.tar.gz' && sleep 0.5s
su vmuser -c 'tar -xzf /home/vmuser/.local/share/ALVR-Launcher/alvr.tar.gz -C /home/vmuser/.local/share/ALVR-Launcher' && sleep 0.5s
su vmuser -c 'mv "/home/vmuser/.local/share/ALVR-Launcher/alvr_launcher_linux/ALVR Launcher" /home/vmuser/.local/share/ALVR-Launcher/ALVR' && sleep 0.5s
su vmuser -c 'rm /home/vmuser/.local/share/ALVR-Launcher/alvr.tar.gz' && sleep 0.5s
su vmuser -c 'rm -r /home/vmuser/.local/share/ALVR-Launcher/alvr_launcher_linux' && sleep 1s

su vmuser -c 'curl -sL https://github.com/alvr-org/ALVR-nightly/releases/latest/download/alvr_streamer_linux.tar.gz -o /home/vmuser/.local/share/ALVR-Launcher/alvrNightly.tar.gz' && sleep 0.5s
su vmuser -c 'tar -xzf /home/vmuser/.local/share/ALVR-Launcher/alvrNightly.tar.gz -C /home/vmuser/.local/share/ALVR-Launcher/installations/Nightly' && sleep 0.5s
su vmuser -c 'rm /home/vmuser/.local/share/ALVR-Launcher/alvrNightly.tar.gz' && sleep 1s

echo -e '#!/bin/bash\nclear\necho "Checking for RTSP Proton updates..."\nrepo=$(curl -sL https://github.com/SpookySkeletons?tab=repositories | grep -iom 1 "proton.\+rtsp")\nrtspVer=$(curl -sL https://github.com/SpookySkeletons/$repo/releases/latest | grep -iom 1 "proton.\+spo" | sed "s/......$//")\ninstRTSP=$(ls /home/vmuser/.local/share/Steam/compatibilitytools.d | grep -iom 1 "proton.\+")\necho -e "Latest RTSP Proton: $rtspVer\\nInstalled RTSP Proton: $instRTSP\\n\\nLaunching ALVR..."\n/home/vmuser/.local/share/ALVR-Launcher/ALVR &\necho "ALVR launched, you can close this terminal window."' > /usr/local/bin/alvr && sleep 0.5s
chmod +x /usr/local/bin/alvr && sleep 1s

su vmuser -c 'mkdir -p /home/vmuser/.local/share/Steam/compatibilitytools.d' && sleep 0.5s
su vmuser -c 'curl -sL https://github.com/SpookySkeletons/$(curl -sL https://github.com/SpookySkeletons?tab=repositories | grep -iom 1 "proton.\+rtsp")/releases/download/proton-rtsp-11.0-20260609-1/proton-rtsp-11.0-20260609-1.tar.gz -o /home/vmuser/.local/share/Steam/compatibilitytools.d/rtsp.tar.gz' && sleep 0.5s
su vmuser -c 'tar -xzf /home/vmuser/.local/share/Steam/compatibilitytools.d/rtsp.tar.gz -C /home/vmuser/.local/share/Steam/compatibilitytools.d' && sleep 0.5s
su vmuser -c 'rm /home/vmuser/.local/share/Steam/compatibilitytools.d/rtsp.tar.gz' && sleep 1s

su vmuser -c "xdg-user-dirs-update" && sleep 1s

su vmuser -c 'echo -e "xfce4-panel &\nxfce4-screensaver &\nxfdesktop &\nblueman-applet &\nconnman-gtk --tray &\nthunar --daemon &\nexec xfwm4" > /home/vmuser/.xinitrc' && sleep 0.5s
su vmuser -c 'echo -e "[[ -f ~/.bashrc ]] && . ~/.bashrc\nstartx" > /home/vmuser/.bash_profile' && sleep 1s

su vmuser -c 'cp /usr/share/applications/xfce4-taskmanager.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/io.github.ilya_zlobintsev.LACT.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/mpv.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/org.xfce.mousepad.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/xfce4-terminal.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/org.shotcut.Shotcut.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/gimp.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/org.prismlauncher.PrismLauncher.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/steam.desktop /home/vmuser/Desktop' && sleep 0.5s
su vmuser -c 'cp /usr/share/applications/org.qutebrowser.qutebrowser.desktop /home/vmuser/Desktop' && sleep 1s

su vmuser -c 'chmod -R +x /home/vmuser/Desktop && sleep 1s

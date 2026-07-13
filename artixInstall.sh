#!/bin/bash
clear
user="vmuser"
echo -e "Automated Artix Installer by Adamina02\n\nSelect install type:\n  1: Virtual machine\n  2: Real hardware"
read -p "Option> " opt
if [ $opt -eq 2 ]; then
  user="adamina"
fi
sleep 1s

echo "Partitioning disks..."
if [ $opt -eq 2 ]; then
  echo -e "label: gpt\ndevice: /dev/nvme0n1\n\n/dev/nvme0n1p1 : start=2048, size=1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B\n/dev/nvme0n1p2 : start=1050624, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4" | sfdisk /dev/nvme0n1
  sleep 0.1s
  echo -e "label: gpt\ndevice: /dev/sda\n\n/dev/sda1 : start=2048, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4" | sfdisk /dev/sda
else
  echo -e "label: gpt\ndevice: /dev/vda\n\n/dev/vda1 : start=2048, size=1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B\n/dev/vda2 : start=1050624, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4" | sfdisk /dev/vda
fi
sleep 1s

echo "Creating filesystems..."
if [ $opt -eq 2 ]; then
  mkfs.vfat -F 32 /dev/nvme0n1p1
  sleep 0.1s
  mkfs.xfs /dev/nvme0n1p2
  sleep 0.1s
  mkfs.xfs /dev/sda1
else
  mkfs.vfat -F 32 /dev/vda1
  sleep 0.1s
  mkfs.xfs /dev/vda2
fi
sleep 1s

echo "Mounting filesystems..."
if [ $opt -eq 2 ]; then
  mount /dev/nvme0n1p2 /mnt
else
  mount /dev/vda2 /mnt
fi
sleep 0.1s
mkdir -p /mnt/boot
sleep 0.1s
if [ $opt -eq 2 ]; then
  mount /dev/nvme0n1p1 /mnt/boot
else
  mount /dev/vda1 /mnt/boot
fi
sleep 1s

echo "Installing base system..."
basestrap /mnt 7zip acpid-dinit amd-ucode android-tools base blueman bluez-dinit chrony-dinit connman-dinit connman-gtk dbus-dinit dbus-dinit-user dinit dosfstools efibootmgr fastfetch ffmpeg ffmpegthumbnailer gimp gnu-free-fonts gsfonts iwd lact-dinit linux-firmware-amdgpu linux-firmware-intel linux-firmware-other linux-firmware-realtek linux-firmware-xz linux-rt mesa metalog-dinit mousepad mpv nano nwg-look opendoas pavucontrol-qt pipewire-audio pipewire-dinit pipewire-jack pipewire-pulse-dinit prismlauncher python-adblock qt6gtk2 qt6-multimedia-ffmpeg qutebrowser ristretto seatd-dinit shotcut thunar thunar-archive-plugin tumbler turnstile-dinit vulkan-mesa-layers vulkan-radeon wireplumber-dinit xarchiver xdg-desktop-portal-gtk xdg-user-dirs xdg-utils xfce4-panel xfce4-pulseaudio-plugin xfce4-screensaver xfce4-screenshooter xfce4-taskmanager xfce4-terminal xfdesktop xfsprogs xfwm4 xlibre-input-libinput xlibre-video-amdgpu xlibre-xserver xorg-xinit yt-dlp zramen-dinit
sleep 1s

echo "Setting up fstab..."
if [ $opt -eq 2 ]; then
  echo -e "/dev/nvme0n1p1 /boot vfat umask=0077,tz=UTC 0 2\n/dev/nvme0n1p2 / xfs defaults,noatime 0 1\n/dev/sda1 /mnt/hdd xfs defaults,noatime,nofail 0 2" > /mnt/etc/fstab
else
  echo -e "/dev/vda1 /boot vfat umask=0077,tz=UTC 0 2\n/dev/vda2 / xfs defaults,noatime 0 1" > /mnt/etc/fstab
fi
sleep 1s

echo "Entering chroot..."
artix-chroot /mnt
sleep 1s

if [ $opt -eq 2 ]; then
  echo "Creating additional mount points..."
  mkdir -p /mnt/hdd
  sleep 0.1s
  chmod -R 777 /mnt/hdd
  sleep 0.1s
  mkdir -p /mnt/usb1
  sleep 0.1s
  mkdir -p /mnt/usb2
  sleep 0.1s
  mkdir -p /mnt/usb3
  sleep 1s
fi

echo "Settting up pacman options..."
echo -e "[options]\nHookDir = /etc/pacman.d/hooks/\nHoldPkg = pacman glibc\nArchitecture = auto\nIgnorePkg = elogind lib32-elogind lib32-polkit polkit sudo\nColor\nCheckSpace\nVerbosePkgLists\nParallelDownloads = 16\nDownloadUser = alpm\nSigLevel = Required DatabaseOptional\nLocalSigLevel = Optional\n[system]\nInclude = /etc/pacman.d/mirrorlist\n[world]\nInclude = /etc/pacman.d/mirrorlist\n[galaxy]\nInclude = /etc/pacman.d/mirrorlist\n[lib32]\nInclude = /etc/pacman.d/mirrorlist" > /etc/pacman.conf
sleep 1s

echo "Setting up pacman hooks..."
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Cleaning package cache...\nWhen = PostTransaction\nExec = /usr/bin/pacman -Sc" > /etc/pacman.d/hooks/cache.hook
sleep 0.1s
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Running fstrim on all mounted filesystems...\nWhen = PostTransaction\nExec = /usr/bin/fstrim -a" > /etc/pacman.d/hooks/disks.hook
sleep 0.1s
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = *\n\n[Action]\nDescription = Checking for orphaned packages...\nWhen = PostTransaction\nExec = /usr/bin/pacman -Qdtt" > /etc/pacman.d/hooks/orphans.hook
sleep 1s

echo "Setting timezone and locale..."
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
sleep 0.1s
echo -e "C.UTF-8 UTF-8" > /etc/locale.gen
sleep 0.1s
locale-gen
sleep 0.1s
echo -e "LANG=C.UTF-8" > /etc/locale.conf
sleep 1s

echo "Creating EFI stub entry..."
if [ $opt -eq 2 ]; then
  efibootmgr -c -d /dev/nvme0n1 -l /vmlinuz-linux-rt -L "Artix Linux" -p 1 -u 'amdgpu.ppfeaturemask=0xffffffff clocksource=tsc initrd=\initramfs-linux-rt.img loglevel=4 mitigations=off root=/dev/nvme0n1p2 rw sysctl.fs.file-max=10485760 sysctl.vm.max_map_count=1048576 sysctl.vm.swappiness=10 tsc=reliable'
else
  efibootmgr -c -d /dev/vda -l /vmlinuz-linux-rt -L "Artix Linux" -p 1 -u 'amdgpu.ppfeaturemask=0xffffffff clocksource=tsc initrd=\initramfs-linux-rt.img loglevel=4 mitigations=off root=/dev/vda2 rw sysctl.fs.file-max=10485760 sysctl.vm.max_map_count=1048576 sysctl.vm.swappiness=10 tsc=reliable'
fi
sleep 1s

echo "Adding user account..."
useradd -G audio,disk,input,network,power,seat,storage,tty,users,video,wheel -m $user
sleep 1s

echo "Setting up doas..."
echo -e "permit keepenv persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel" > /etc/doas.conf
sleep 1s

echo "Setting up networking..."
echo -e "antartix" > /etc/hostname
sleep 0.1s
echo -e "127.0.0.1 localhost\n::1 localhost" > /etc/hosts
sleep 0.1s
echo -e "[General]\nAllowHostnameUpdates=false\nPreferredTechnologies=ethernet,wifi" > /etc/connman/main.conf
sleep 1s

echo "Setting environment variables..."
echo -e "EDITOR=nano\nLD_BIND_NOW=1\nQT_QPA_PLATFORMTHEME=gtk2" > /etc/environment
sleep 1s

echo "Setting up TTY..."
echo -e "ACTIVE_CONSOLES=\"/dev/tty1\"" > /etc/dinit.d/config/console.conf
sleep 0.1s
echo -e "GETTY_ARGS=\"-a $user -J\"\nGETTY_BAUD=38400\nGETTY_TERM=linux" > /etc/dinit.d/config/agetty-tty1.conf
sleep 1s

echo "Setting up turnstile..."
echo -e "debug = no\nbackend = dinit\ndebug_stderr = no\nlinger = no\nrundir_path = /run/user/%u\nmanage_rundir = yes\nexport_dbus_address = yes\nlogin_timeout = 60\nroot_session = no" > /etc/turnstile/turnstiled.conf
sleep 1s

echo "Setting up mkinitcpio..."
echo -e "MODULES=(nct6683 ntsync)\nBINARIES=()\nFILES=()\nHOOKS=(base udev autodetect microcode modconf kms keyboard keymap block filesystems fsck)\nCOMPRESSION=\"zstd\"\nCOMPRESSION_OPTIONS=()\nMODULES_DECOMPRESS=\"no\"" > /etc/mkinitcpio.conf
sleep 0.1s
mkinitcpio -P
sleep 1s

echo "Setting up ZRAM..."
echo -e "ZRAM_COMP_ALGORITHM=zstd\nZRAM_MAX_SIZE=8192\nZRAM_PRIORITY=32767\nZRAM_SIZE=32\nZRAMEN_QUIET=1\nZRAMEN_SWAPON_DISCARD=true" > /etc/dinit.d/config/zramen.conf
sleep 1s

echo "Setting file descriptor limits..."
echo -e "$user hard nofile 1048576\n$user soft nofile 1048576" > /etc/security/limits.conf
sleep 1s

echo "Setting up services..."
ln -s /etc/dinit.d/acpid /etc/dinit.d/boot.d/acpid
sleep 0.1s
ln -s /etc/dinit.d/bluetoothd /etc/dinit.d/boot.d/bluetoothd
sleep 0.1s
ln -s /etc/dinit.d/chrony /etc/dinit.d/boot.d/chrony
sleep 0.1s
ln -s /etc/dinit.d/connmand /etc/dinit.d/boot.d/connmand
sleep 0.1s
ln -s /etc/dinit.d/dbus /etc/dinit.d/boot.d/dbus
sleep 0.1s
ln -s /etc/dinit.d/lact /etc/dinit.d/boot.d/lact
sleep 0.1s
ln -s /etc/dinit.d/metalog /etc/dinit.d/boot.d/metalog
sleep 0.1s
ln -s /etc/dinit.d/seatd /etc/dinit.d/boot.d/seatd
sleep 0.1s
ln -s /etc/dinit.d/turnstiled /etc/dinit.d/boot.d/turnstiled
sleep 0.1s
ln -s /etc/dinit.d/zramen /etc/dinit.d/boot.d/zramen
sleep 0.1s
su $user -c "mkdir -p /home/$user/.config/dinit.d/boot.d"
sleep 0.1s
ln -s /etc/dinit.d/user/dbus /home/$user/.config/dinit.d/boot.d/dbus
sleep 0.1s
ln -s /etc/dinit.d/user/pipewire /home/$user/.config/dinit.d/boot.d/pipewire
sleep 0.1s
ln -s /etc/dinit.d/user/pipewire-pulse /home/$user/.config/dinit.d/boot.d/pipewire-pulse
sleep 0.1s
ln -s /etc/dinit.d/user/wireplumber /home/$user/.config/dinit.d/boot.d/wireplumber
sleep 1s

echo "Updating pacman databases..."
pacman -Syu
sleep 1s

echo "Installing additional applications..."
pacman -S --noconfirm lib32-mesa lib32-vulkan-mesa-layers lib32-vulkan-radeon steam --assume-installed lib32-elogind
sleep 0.1s
pacman -S --noconfirm mugshot xfce4-whiskermenu-plugin --assume-installed polkit
sleep 1s

echo "Running some commands as user..."
su $user -c "xdg-user-dirs-update"
sleep 0.1s
su $user -c 'echo -e "xfce4-panel &\nxfce4-screensaver &\nxfdesktop &\nblueman-applet &\nconnman-gtk --tray &\nthunar --daemon &\nexec xfwm4" > /home/$user/.xinitrc'
sleep 0.1s
su $user -c 'echo -e "[[ -f ~/.bashrc ]] && . ~/.bashrc\nstartx" > /home/$user/.bash_profile'

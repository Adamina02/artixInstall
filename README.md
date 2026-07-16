# I use Artix btw
I also got tired of typing a very long string of commands to install Artix in VMs....

This is a really opinionated install of Artix Linux with dinit specifically tailored to be rather minimal.

It's also weird because I'm using:
- acpid+seatd+turnstiled instead of elogind, also no polkit either
- doas instead of sudo
- EFI stub instead of GRUB or other bootloader
- XLibre instead of X11
- dinit instead of systemd, kinda obvious
- Connman instead of NetworkManager
- A trimmed version of XFCE desktop instead of the full group package
- No AUR, standard Arch, testing, or third-party repositories

If for some reason you want to use this, go ahead!
## Installation
Make sure that your VM or hardware is using UEFI, then run one of these inside a dinit Artix base image as root.
### VMs:
```bash
curl -sL https://raw.githubusercontent.com/Adamina02/artixInstall/main/vmInst.sh | bash
```
### Real hardware:
_For real hardware, you will likely need to make changes to the file, this is made for my PC!_
```bash
curl -sL https://raw.githubusercontent.com/Adamina02/artixInstall/main/inst.sh | bash
```
#
For security reasons, this script does not set account passwords, please run the following to do so:
```bash
artix-chroot /mnt #The script automatically kicks you out of chroot and I don't know why!
passwd
passwd vmuser #Replace vmuser with adamina or the user you changed it to if not a VM.
exit
umount -R /mnt
reboot
```

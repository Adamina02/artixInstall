# I use Artix btw
I also got tired of typing a very long string of commands to install Artix in VMs...

This is a really opinionated install of Artix Linux with dinit specifically tailored to be rather minimal.  

It's also weird because I'm using:
- acpid+seatd+turnstiled instead of elogind
- doas instead of sudo
- EFI stub instead of GRUB or other bootloader
- XLibre instead of X11
- dinit instead of systemd, kinda obvious
- connman instead of NetworkManager
- A trimmed version of XFCE desktop instead of the full group package
- No AUR, standard Arch, testing, or third-party repositories

If for some reason you want to use this, go ahead:  
```bash
curl -sL <link here in a second hold on!> | bash
```
But it's mostly tailed for my PC so you'll probably need to tweak it a bit.

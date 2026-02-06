# 🐧 Install Linux (beginner guide)

Short, practical, and designed for first‑time users.

## 🧭 1) Choose your install path

- 🟢 **Easy (recommended):** GUI installer with a desktop included.

    | Name | Linux Based | Desktop Environment (default) |
    | --- | --- | --- |
    | [Fedora KDE](https://fedoraproject.org/kde/) | Fedora | KDE Plasma |
    | [Linux Mint](https://linuxmint.com/download.php) | Debian/Ubuntu | Cinnamon |
    | [Ubuntu](https://ubuntu.com/download/desktop) | Debian | GNOME |
    | [Pop!_OS](https://system76.com/pop/download/) | Ubuntu | GNOME |
    | [Zorin OS](https://zorin.com/os/download/) | Ubuntu | GNOME |
    | [CachyOS](https://cachyos.org/download/) | Arch | KDE Plasma |
    | [Manjaro](https://manjaro.org/products/download/x86) | Arch | KDE Plasma |

- 🟡 **Intermediate:** guided CLI or semi‑automated install.
    - Archinstall (Arch)
    - Debian text installer
    - Void installer
    - In this repo: [script/arksys.sh](script/arksys.sh) and [script/archinstall/archisntall-config.sh](script/archinstall/archisntall-config.sh)

- 🟠 **Advanced:** full manual install (no guided setup).
    - [Arch manual install](https://wiki.archlinux.org/title/Installation_guide)
    - [Gentoo manual install](https://wiki.gentoo.org/wiki/Installation)
    - [Void manual install](https://docs.voidlinux.org/installation/index.html)

- 🔴 **Hardcore:** build your own distro.
    - [Archiso profile](https://gitlab.archlinux.org/archlinux/archiso/-/blob/master/docs/README.profile.rst) + [Calamares](https://calamares.codeberg.page/)
    - [Debian live-build](https://www.debian.org/devel/debian-live/)
    - [LFS (Linux From Scratch)](https://www.linuxfromscratch.org/lfs/)

## 📥 2) Download the ISO

- Get the ISO from the official website of your chosen distro.
- Verify the checksum if the site provides it.

## 💾 3) Create a bootable USB

Use a GUI tool:

- Windows: Rufus
- Linux/macOS: BalenaEtcher
- Multi‑ISO: Ventoy

Or use the CLI (Linux/macOS). 

> Replace `/dev/sdb` with your actual USB device.

```bash
sudo fdisk -l                                          # Find the disk
umount /dev/sdb*                                       # Unmount the disk
sudo mkfs.vfat /dev/sdb                                # Format the disk
sudo dd if=~/Downloads/arch.iso of=/dev/sdb bs=4M status=progress  # Write ISO
```

## 🔧 4) Boot and install

1. Reboot and open the boot menu (often F12, Esc, or Del).
2. Select the USB drive.
3. Follow the installer prompts.
   - Choose language and keyboard.
   - Pick time zone and user account.
   - Use automatic partitioning if you are new.

## ✅ 5) First boot checklist

- Update your system.
- Install drivers if needed (GPU, Wi‑Fi).
- Install basic apps you use daily.

## 📌 After install

- Apps list: see [linux-software.md](linux-software.md)
- Post‑install guide: <https://github.com/arksys-os/arksys_post-install>

## 🔗 References

- <https://archlinux.org/download/>
- <https://wiki.archlinux.org/title/Installation_guide>
- <https://fedoraproject.org/>
- <https://ubuntu.com/download>
- <https://linuxmint.com/download.php>

#!/bin/bash

set -euo pipefail

echo "arksys manual Arch install"

if [[ ${EUID:-0} -ne 0 ]]; then
    echo "Please run as root (sudo)."
    exit 1
fi

# Prompt for device to use for installation
read -rp "Enter the device to install Arch Linux (e.g., /dev/nvme0n1 or /dev/sda): " device
if [[ -z "${device}" || ! -b "${device}" ]]; then
    echo "Device not found: ${device}"
    exit 1
fi

echo "WARNING: This will erase all data on ${device}."
read -rp "Type YES to continue: " confirm
if [[ "${confirm}" != "YES" ]]; then
    echo "Aborted."
    exit 0
fi

# 0. Set the console keyboard layout (optional)
# loadkeys es

# 1.1. Update the system clock
timedatectl set-ntp true

# 1.2. Partition the disk
swap_size=$(free --mebi | awk '/Mem:/ {print $2}')
swap_end=$(( swap_size + 129 + 1 ))MiB

parted --script "${device}" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 129MiB \
    set 1 boot on \
    mkpart primary linux-swap 129MiB ${swap_end} \
    mkpart primary ext4 ${swap_end} 100%

# Identify partitions
part_boot="$(ls "${device}"* | grep -E "^${device}p?1$")"
part_swap="$(ls "${device}"* | grep -E "^${device}p?2$")"
part_root="$(ls "${device}"* | grep -E "^${device}p?3$")"

# Wipe filesystem signatures
wipefs "${part_boot}"
wipefs "${part_swap}"
wipefs "${part_root}"

# 1.3. Format the partitions
mkfs.vfat -F32 "${part_boot}"
mkswap "${part_swap}"
mkfs.ext4 "${part_root}"

# 1.4. Mount the file systems
swapon "${part_swap}"
mount "${part_root}" /mnt
mkdir -p /mnt/boot
mount "${part_boot}" /mnt/boot

# 2. Install base system
pacstrap /mnt base linux linux-firmware

# 3. Configure the system
# 3.1. Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# 3.2. Chroot into the new system
arch-chroot /mnt /bin/bash <<EOF
# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Generate locales
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Set hostname
echo 'arksys' > /etc/hostname

# Set console keymap
echo 'KEYMAP=es' > /etc/vconsole.conf

# Network configuration
echo '127.0.0.1 localhost' > /etc/hosts
echo '::1 localhost' >> /etc/hosts
echo '127.0.1.1 arksys.localdomain arksys' >> /etc/hosts

# Create root password
echo 'root:123' | chpasswd

# Create a new user
useradd -m -G wheel,audio,video,optical,storage ark
echo 'ark:123' | chpasswd

# Allow members of wheel group to execute any command with sudo
sed -i '/%wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers

# Install and configure bootloader (assuming UEFI system)
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
mkdir -p /boot/EFI
mount "${part_boot}" /boot/EFI
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=grub_uefi --recheck

# Generate grub configuration
grub-mkconfig -o /boot/grub/grub.cfg
EOF

# 4. Unmount and reboot
umount -R /mnt
reboot

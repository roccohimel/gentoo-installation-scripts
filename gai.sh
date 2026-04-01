clear
echo "ROCCO HIMEL'S PERSONALIZED GENTOO INSTALLATION SCRIPT"

lsblk
cfdisk /dev/nvme0n1
mkfs.ext4 /dev/nvme0n1p3
mkfs.fat -F 32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2

clear
mkdir -p /mnt/gentoo
mount /dev/nvme0n1p3 /mnt/gentoo
swapon /dev/nvme0n1p2

clear
date
cd /mnt/gentoo
links https://www.gentoo.org/downloads/mirrors
tar xpvf stage3-* --xattrs-include='*.*' --numberic-owner
ls

clear
nano /mnt/gentoo/etc/portage/make.conf

clear
cp --dereference /etc/resolv.conf /mnt/gentoo/etc
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
chroot /mnt/gentoo /bin/bash <<EOF
source /etc/profile
export PS1="(chroot) $PS1"
lsblk
mkdir -p boot/efi
mount /dev/nvme0n1p1 boot/efi
emerge-webrsync
emerge --sync

clear
emerge --ask --verbose --update --deep --changed-use @world

clear
ln -sf ../usr/share/zoneinfo/America/New_York /etc/localtime
nano /etc/locale.gen
locale-gen
eselect locale list
eselect locale set 4
env-update && source /etc/profile && export PS1="(chroot) $PS1"

clear
echo 'sys-kernel/linuxfirmware @BINARY-REDISTRIBUTABLE' | tee -a /etc/portage/package.license
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-firmware/sof-firmware

clear
echo "sys-kernel/installkernel dracut grub" >> /etc/portage/package.use/installkernel
emerge --ask sys-kernel/installkernel
emerge --ask sys-kernel/gentoo-kernel-bin
echo "root=/dev/nvme0n1p3" > /etc/cmdline
emerge --config sys-kernel/gentoo-kernel-bin

clear
nano /etc/fstab

clear
nano /etc/conf.d/hostname
nano /etc/host
emerge --ask net-misc/networkmanager
etc-update
emerge --ask net-misc/networkmanager
rc-update add NetworkManager default

clear
passwd
useradd -m -G users,wheel,audio,video,tty -s /bin/bash roccohimel
passwd roccohimel
emerge --ask sudo
visudo
cd

clear
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge --ask sys-boot/grub efibootmgr fastfetch
grub-install --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
EOF

clear
umount -R /mnt/gentoo

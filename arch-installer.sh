#This script is made mostly for my use, its not "The method of installing arch".
#You will learn from it anyways :))
#This doesn't automate everything, it just makes things less messier.
#Script to be run without chroot.....Dont mind just saying
#Just wget the script in /mnt or git clone there and please read all comments first
#You might need an efi partition prebuilt, script as of now doesn't do that.

echo "Welcome to Arch Linux minimal installer"
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
timedatectl set-timezone Asia/Kolkata #Please do update your timezone
echo "Enter the drive: "
read drive
cfdisk $drive 
echo "Enter the linux partition: "
read main_partition
mkfs.ext4 $main_partition 
read -p "Did you also created efi partition? [yn]" answer

if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efi_partition
  mkfs.vfat -F 32 $efi_partition
fi

mount $partition /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#part2$/d' arch_install.sh > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2
#This part will run in chroot 
#ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime 
#This is because of official wiki, I usually prefer doing beforehand...Your choice 
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
pacman --noconfirm -S grub efibootmgr os-prober
echo "Enter EFI partition: " 
read efi_partition
mkdir /boot/efi
mount $efi_partition /boot/efi 
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
pacman --noconfirm -S pulseaudio pulseaudio-alsa alsa-utils xorg vulkan-intel alacritty i3gaps i3wm i3blocks i3lock i3status xorg-xinit redshift vlc  firefox-developer-edition vim vim-plugins vi nano wget dhcpcd xdg-user-dirs zsh networkmanager lightdm lightdm-gtk-greeter lightdm-webkit-theme-litarvan
systemctl enable NetworkManager.service 
systemctl enable lightdm.service
visudo
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/bash $username
passwd $username
echo "Reboot now and set the "rest" on reboot...where rest is a DE"



# Installing the Arch Linux OS

###### Resources
[Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide)  
[Installation Template](https://wiki.archlinux.org/index.php/User:Erkexzcx#Basic_Arch_Linux_installation)  
[Wiki | Arch](https://wiki.archlinux.org/)

### Pre-installation
Download the newest Arch Linux release (and optionally signature). Verified checksum in Windows 10 with Powershell (open Powershell in the ISO directory):
```
certutil -hashfile <filename> md5
certutil -hashfile <filename> sha1
```
From an existing Arch Linux installation run:
```
pacman-key -v archlinux-version-x86_64.iso.sig archlinux-version-x86_64.iso
```
In Windows write ISO to USB with Rufus default settings (MBR, FAT32). Boot via BIOS.

Using dd run the following command, replacing the path and drive appropriately. The cmd might have to be run with sudo priviledges. Boot via BIOS.
```
dd bs=4M if=path/to/archlinux.iso of=/dev/sdx status=progress oflag=sync
```
Check keymaps and modify appropriately:
```
ls /usr/share/kbd/keymaps/**/*.map.gz
loadkeys dk
```
Verify UEFI mode enabled:
```
ls /sys/firmware/efi/efivars
```
Verify network is listed and connected (wired):
```
ping www.google.com
```
OPTIONAL CONNECT VIA WI-FI:
Make sure the card is not blocked by executing `rfkill`. If blocked: `rfkill unblock all`
1. `iwctl` for the wi-fi interactive prompt
2. List devices: `<device> list`
3. Scan for networks (no output): `station <device> scan`
4. List networks: `station <device> get-networks`
5. Connect to network: `station <device> connect <SSID>`
6. start daemon for all network interfaces: `systemctl start dhcpcd.service`

Use `timedatectl` to ensure the system clock is accurate:
```
timedatectl set-ntp true
```
To check the service status, use: `timedatectl status`.


### Partitioning
Use `lsblk` and `lsblk -f` to identify your drives.
1. (opt) WARNING! The following command completely erases all data on the drive specified (replace X with your drive): `sgdisk --zap-all /dev/sdX`.
2. List drives with `lsblk` and identify which one to use for the Linux partition, then setup partitions for Linux: `cgdisk /dev/sdX`.
3. Create the first partition (boot) as EFI. Default first sector, size: `1G`, type: `ef00`, called `boot`.
4. Create the second partition (Linux file system). Default first sector, size: remaining space, type `8300`, called `arch` (Or any other name you deem appropriate).
5. Write and quit.
6. Verify partitions with `lsblk`.

Now we can format and mount the partitions:
1. For the `arch` partition: `mkfs.ext4 /dev/sdX#`, replace X and # with the letter and number corresponding to the previously made `arch` partition.
2. For the `boot` partition: `mkfs.fat -F32 /dev/sdX#`, replace X and # with the letter and number corresponding to the previously made `boot` partition.
3. Mount the `arch` system partition: `mount /dev/sdX# /mnt`.
4. Create boot directory inside the first mount point: `mkdir /mnt/boot`.
5. Mount the `boot` EFI partition: `mount /dev/sdX# /mnt/boot`.
6. Verify with `lsblk`.

### Installing the base system
1. Rearrange mirrorlist by moving mirrors close to your location to the top: `vim /etc/pacman.d/mirrorlist`.
2. Use pacstrap to install the basic system packages, as well as an optional secondary (more stable) kernel in case the bleeding edge kernel has issues: `pacstrap /mnt base base-devel linux linux-lts linux-firmware`.
3. Tell the system to remount the partitions in the correct positions: `genfstab -U /mnt > /mnt/etc/fstab`.
4. (opt) check if fstab was generated correctly: `cat /mnt/etc/fstab`.
5. Enter chroot: `arch-chroot /mnt`.
6. Install text editor: `pacman -S neovim`.

### Localization
1. List zoneinfo: `ln -sf /usr/share/zoneinfo/`.
2. Pick timezone: `ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime`.
3. Run localtime to verify: `ls -l /etc/localtime`.
4. Update the hardware clock: `hwclock --systohc`.
   - Go to https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows for instructions on how to sync the time on a dual boot system.
6. Open `locale.gen`: `nvim /etc/locale.gen`.
7. Uncomment the locales you want.
8. Execute `locale-gen`.
9. Open `locale.conf`: `nvim /etc/locale.conf`.
10. Enter `LANG=en_DK.UTF-8` and write to file.
11. Open `vconsole.conf`: `nvim /etc/vconsole.conf`.
12. Enter `KEYMAP=dk` and write to file.

### Internet connection
Install NetworkManager:
```
pacman -S networkmanager
```
Enable NetworkManager on boot:
```
systemctl enable NetworkManager.service
```

### Hostname
Setting up the name of the machine.
1. create the file: `nvim /etc/hostname`.
2. name the computer: `somename`.
3. go to the hosts file: `nvim /etc/hosts`.
4. enter the defaults, replacing `somename` with whatever the computer was named:
```
127.0.0.1      localhost
::1            localhost
127.0.1.1      somename.localdomain somename
```

### Microcode updates
Install AMD or Intel microcode updates to the system:
```
pacman -S amd-ucode       # For AMD processors only
pacman -S intel-ucode     # For Intel processors only
```

### Bootloader
1. Install required packages: `pacman -S grub os-prober efibootmgr ntfs-3g`.
2. Install grub: `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
###### NOTE
> OS-prober and GRUB might need additional configuration here. In a new update os-prober seems to be disabled by default by GRUB. Also when working with multiple kernels, it might be easier to disable the submenu. This can be fixed by appending the following lines to `/etc/default/grub`:
> 
> `GRUB_DISABLE_SUBMENU=y`.         # This should be at the top of the file.  
> `GRUB_DISABLE_OS_PROBER=false`.   # This should be at the bottom of the file.  
> 
> Remember to (re)generate the GRUB config file in step 3.
>
> I had some difficulties getting os-prober to reckognize Windows while doing these steps. To fix it I did the remaining steps of this installation guide and rebooted into the actual system. When running os-prober it now detects the Windows boot partition.
> So after rebooting run `os-prober` followed by `grub-mkconfig -o /boot/grub/grub.cfg`
3. Make the config: `grub-mkconfig -o /boot/grub/grub.cfg`.

Optionally follow these steps to make Windows the default boot choice:
Add the following line to `/etc/grub.d/40_custom`, where the number corresponds to the boot entry you want as default, in my case Windows is listed as the third entry in Grub, starting from 0:
```
set default=2
```
Then re-generate the main configuration file:
```
grub-mkconfig -o /boot/grub/grub.cfg
```
It is also possible to change the default timeout with `set timeout=#`, replacing # with a number. set to -1 for indefinite time to choose. The format is in seconds.

### Password
Set root password: `passwd`.

### Reboot
Exit back into the live environment and run `reboot`.

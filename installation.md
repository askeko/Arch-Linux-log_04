# Installing the Arch Linux OS

###### Resources
[Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide)  
[Installation Template](https://wiki.archlinux.org/index.php/User:Erkexzcx#Basic_Arch_Linux_installation)  
[Wiki | Arch](https://wiki.archlinux.org/)

## Pre-installation
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

### Partitioning
Use `lsblk` and `lsblk -f` to identify your drives.

1. (opt) WARNING! The following command completely erases all data on the drive specified (replace X with your drive): `sgdisk --zap-all /dev/sdX`.
2. List drives with `lsblk` and identify which one to use for the Linux partition, then setup partitions for Linux: `cgdisk /dev/sdX`.
3. Create the first partition (boot) as EFI. Default first sector, size: `500M`, type: `ef00`, called `boot`.
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

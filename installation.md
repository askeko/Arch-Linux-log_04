# Installing the Arch Linux OS

[Installation Guide]: https://wiki.archlinux.org/index.php/Installation_guide
[Installation Template]: https://wiki.archlinux.org/index.php/User:Erkexzcx#Basic_Arch_Linux_installation
[Arch Wiki]: https://wiki.archlinux.org/
[Arch Download]: https://archlinux.org/download/
[Dual Boot]: https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows

<!--toc:start-->
- [Installing the Arch Linux OS](#installing-the-arch-linux-os)
  - [Resources](#resources)
  - [Pre-installation](#pre-installation)
    - [Installation Image](#installation-image)
    - [Verify Checksum](#verify-checksum)
    - [Prepare Installation Medium](#prepare-installation-medium)
      - [Windows](#windows)
      - [GNU/Linux](#gnulinux)
  - [Installation](#installation)
    - [Keyboard Layout](#keyboard-layout)
    - [Font](#font)
    - [Check UEFI](#check-uefi)
    - [Network Setup](#network-setup)
      - [Optional connect via Wi-Fi](#optional-connect-via-wi-fi)
    - [Set System Clock](#set-system-clock)
    - [Partitioning](#partitioning)
    - [(opt) Configure Mirrors](#opt-configure-mirrors)
    - [Installing the Base System](#installing-the-base-system)
    - [Time](#time)
    - [Localization](#localization)
    - [Internet connection](#internet-connection)
    - [Hostname](#hostname)
    - [Bootloader](#bootloader)
      - [On multi-booting](#on-multi-booting)
        - [Extra multi-boot options](#extra-multi-boot-options)
    - [Password](#password)
    - [Reboot](#reboot)
<!--toc:end-->

## Resources

[Installation Guide]  
[Installation Template]  
[Wiki | Arch][Arch Wiki]

## Pre-installation

### Installation Image

[Download][Arch Download] the newest Arch Linux release (and optionally signature).

### Verify Checksum

Verified checksum in Windows 10 with Powershell
(open Powershell in the ISO directory):

```sh
# Replace file_name with the name of the file
certutil -hashfile filename md5
certutil -hashfile filename sha1
```

From an existing Arch Linux installation run (replacing version with the
version number):

```sh
# Replace version with the version of the installation image
pacman-key -v archlinux-version-x86_64.iso.sig archlinux-version-x86_64.iso
```

### Prepare Installation Medium

#### Windows

Write ISO to USB with `Rufus` default settings (MBR, FAT32). Boot via BIOS.

#### GNU/Linux

Using `dd` run the following command, replacing the path and drive appropriately.
The cmd might have to be run with sudo priviledges. Boot via BIOS.

```sh
dd bs=4M if=path/to/archlinux.iso of=/dev/sdx status=progress oflag=sync
```

## Installation

### Keyboard Layout

Check keymaps and modify appropriately:

```sh
ls /usr/share/kbd/keymaps/**/*.map.gz
# Example:
loadkeys dvorak-no
```

Alternatively `loadkeys dk` or `loadkeys en` for regular qwerty danish and
english layouts.

### Font

Set font with:

```sh
setfont some_font # Replace some_font with an actual font
```

Fonts are located at `/usr/share/kbd/consolefonts/`. I like `ter-v22n`.

### Check UEFI

Verify UEFI mode enabled, it should return 64:

```sh
cat /sys/firmware/efi/fw_platform_size
```

### Network Setup

Verify network is listed and connected (wired):

```sh
ping www.google.com
```

#### Optional connect via Wi-Fi

Make sure the card is not blocked by executing `rfkill`.
If blocked:

```sh
rfkill unblock wlan
```

Connect to a network using `iwctl`:

```sh
iwctl # for the wi-fi interactive prompt
[iwctl] device list # list devices
[iwctl] station <device> scan # scan for networks
[iwctl] station <device> get-networks # list scanned networks
[iwctl] station <device> connect <SSID> # connect to network
```

Start the daemon for all network interfaces:

```sh
systemctl start dhcpcd.service
```

### Set System Clock

Use `timedatectl` to ensure the system clock is accurate:

```sh
timedatectl set-ntp true
```

To check the service status, use:

```sh
timedatectl status
```

### Partitioning

Use `lsblk` and `lsblk -f` to identify your drives.

Erase all data on a drive (BE CAREFUL!!!):

```sh
sgdisk --zap-all /dev/X # Replace 'X' with your drive. (Usually nvmeX or sdaX)
```

Setup partitions using `cgdisk`:

```sh
cgdisk /dev/X # Replace 'X' with your drive. (Usually nvmeX or sdaX)
```

Create partitions using the following partition layout (modify as needed):

| Partition                   | First sector | Size        | Type   | Name   |
| --------------------------- | ------------ | ----------- | ------ | ------ |
| `/dev/efi_system_partition` | `default`    | `1G`        | `ef00` | `boot` |
| `/dev/swap_partition`       | `default`    | `8G`        | `8200` | `swap` |
| `/dev/root_partition`       | `default`    | `remaining` | `8300` | `arch` |

After creating the partitions `write` and `quit`. Verify partitions with `lsblk`.

Now we can format and mount the partitions:

```sh
# Format partitions:
mkfs.ext4 /dev/root_partition
mkswap /dev/swap_partition
mkfs.fat -F 32 /dev/efi_system_partition
# Mount partitions
mount /dev/root_partition /mnt
mount --mkdir /dev/efi_system_partition /mnt/boot
# Enable swap
swapon /dev/swap_partition
```

Verify with `lsblk`.

### (opt) Configure Mirrors

Automatically update mirrorlist:

```sh
systemctl restart reflector.service
```

### Installing the Base System

Install essential packages (replace amd for intel if necessary)

```sh
pacstrap /mnt base base-devel linux linux-firmware linux-headers amd-ucode
```

Generate fstab to remount partitions in the correct positions:

```sh
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab # Optionally check if fstab was generated correctly
```

Enter chroot:

```sh
arch-chroot /mnt
```

Install a text editor for configuring the rest of the installation:

```sh
pacman -S neovim
```

### Time

Set time zone:

```sh
# Replace region and city as appropriate
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
ls -l /etc/localtime # Optionally verify that time zone is set correctly.
```

Run hwclock to generate `/etc/adjtime`, assumes the hardware clock is set to UTC:

```sh
hwclock --systohc
```

- Go to [dual boot with windows][Dual Boot]
  for instructions on how to sync the time on a dual boot system.

Synchronize with NTP (time) servers and set the correct datetime:

```sh
systemctl enable systemd-timesyncd.service
```

### Localization

Uncomment desired locales:

```sh
nvim /etc/locale.gen
locale-gen # generate uncommented locales
```

Create the following file to set the LANG variable:

```sh
echo LANG=en_DK.UTF-8 > /etc/locale.conf
```

Create the following file to make console keyboard layout persistent:

```sh
echo KEYMAP=dvorak-no > /etc/vconsole.conf
```

### Internet connection

Install NetworkManager:

```sh
pacman -S networkmanager
```

Enable NetworkManager on boot:

```sh
systemctl enable NetworkManager.service
```

### Hostname

Create the following file to set the hostname of the computer:

```sh
echo some_name > /etc/hostname # replace some_name with some name
```

Create the following file to make the computer accessible in your LAN via its hostname:

```sh
/etc/hosts
-------------
127.0.0.1 localhost
::1 localhost
127.0.1.1 some_name.localdomain some_name # replace some_name with the hostname
```

### Bootloader

```sh
# Optionally also install os-prober if multi-booting
pacman -S grub efibootmgr ntfs-3g
# Install grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg # Make the grub config file
```

#### On multi-booting

> OS-prober and GRUB might need additional configuration here.
> In a new update os-prober seems to be disabled by default by GRUB.
> Also when working with multiple kernels, it might be easier to disable
> the submenu. This can be fixed by appending the following lines to
> `/etc/default/grub`:
>
> `GRUB_DISABLE_SUBMENU=y` # This should be at the top of the file.
> `GRUB_DISABLE_OS_PROBER=false` # This should be at the bottom of the file.
>
> Remember to (re)generate the GRUB config.
>
> I had some difficulties getting os-prober to recognize Windows while doing
> these steps. To fix it I did the remaining steps of this installation guide and
> rebooted into the actual system. When running os-prober it now detects the
> Windows boot partition. Remember to run mkconfig again after running os-prober.

##### Extra multi-boot options

Optionally follow these steps to make Windows the default boot choice:
Add the following line to `/etc/grub.d/40_custom`, where the number corresponds
to the boot entry you want as default, in my case Windows is listed as the third
entry in Grub, starting from 0:

It is also possible to change the default timeout with `set timeout=#`,
replacing # with a number. set to -1 for indefinite time to choose. The format
is in seconds.

```sh
/etc/grub.d/40_custom
---------------------
set default=2
```

Then re-generate the main configuration file:

```sh
grub-mkconfig -o /boot/grub/grub.cfg
```

### Password

Set root password:

```sh
passwd
```

### Reboot

Exit chroot and reboot:

```sh
exit
reboot
```

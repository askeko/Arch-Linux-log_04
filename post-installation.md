# Post installation
#### todo
##### absrice-dwm
* colors
* qt theme?
* cursor

#### Longterm improvements
* Look through documentation of lf
* A more simple bar

### The install script
After following the steps in the [installation guide](https://github.com/askeko/Arch-Linux-log_04/blob/main/installation.md).
1. `curl -LO https://raw.githubusercontent.com/askeko/AARBS-dwm/main/aarbs.sh`
	* OR: `curl -LO https://raw.githubusercontent.com/askeko/AARBS-wayland/main/aarbs.sh`
3. `sh aarbs.sh`

after logging in, to install some extra dependencies for the system: `curl -LO https://raw.githubusercontent.com/askeko/Arch-Linux-log_04/main/extras.sh` 

This installs the following: 

Install Rust: `rustup default stable`

Install NVM+Node: [nvm](https://github.com/nvm-sh/nvm)

### Importing dotfiles
After running the script, simply run the following command to import all my dotfiles:
```
chezmoi init --apply https://github.com/askeko/absrice-dwm.git
```
You might have to rebuild bat cache for the bat theme to work: `bat cache --build`.

## Xorg
### If startx
The keyboard layout will by default be set to US (you can check options with `setxkbmap -print -verbose 10`), to change this use the following command: `setxkbmap -model pc105 -layout dk`.
To make it persistent add to xprofile.

### Mouse Acceleration
To disable mouse acceleration create/modify the file `/etc/X11/xorg.conf.d/50-mouse-acceleration.conf`:
```
Section "InputClass"
	Identifier "My Mouse"
	MatchIsPointer "yes"
# set the following to 1 1 0 respectively to disable acceleration.
	Option "AccelerationNumerator" "1"
	Option "AccelerationDenominator" "1"
	Option "AccelerationThreshold" "0"
EndSection
```

### Rofi as dmenu replacement
`sudo ln -s /usr/bin/rofi /usr/bin/dmenu` (done in AARBS script)

### Nvidia drivers
1. Packages: `pacman -S nvidia nvidia-settings`
2. Remove `kms` from the `HOOKS` array in `/etc/mkinitcpio.conf` and regenerate the initramfs with `sudo mkinitcpio -P`. This will prevent the initramfs from containing the nouveau module making sure the kernel cannot load it during early boot. 
3. Sudo into nvidia-settings and check both `Force Composition Pipeline` and `Force Full Composition Pipeline` if you experience screen tearing. Save to X configuration file. You may have to manually create the file `touch /etc/X11/xorg.conf` first.

### Cursor theme fix for Polybar
1. Copy the theme folder (in my case "volantes_cursors") from ~/.local/share/icons/ to /usr/share/icons/. 
2. Edit the file /usr/share/icons/default/index.theme with the name of your theme as shown below:
```
[Icon Theme]
Inherits=volantes_cursors
```

#### Nvidia mouse/UI fix
The proprietary nvidia drivers seem to mess up mouse and UI scaling in a weird way. It only seems to occur when one monitor is landscape and the other is portrait. I've done a few things to fix this:
1. In `/etc/X11/xorg.conf` enter the following under the `Screen` or `Device` section: `Option              "DPI" "96 x 96"`.
2. Uncomment the `xrdb` command in `~/.config/x11/xprofile`.
3. Add `Xcursor.size: 16` to `~/.config/x11/xresources`. >>>>>> This seems to work? <<<<<<<
4. Maybe adding `xrandr --dpi 96` to the beginning of `~/.config/x11/xprofile` is enough?

### Integrated AMD gpu + screen tearing fix
1. `pacman -S xf86-video-amdgpu`
2. create `/etc/X11/xorg.conf.d/20-amd-gpu.conf` and input:
```
Section "Device
	Identifier "AMD Graphics"
	Driver     "amdgpu"
	Option     "TearFree" "true"
EndSection
```

### Screen brightness
1. Install acpilight: `pacman -S acpilight`.

## Wayland / Hyprland
Might have to apply GTK/QT themes with qt5ct, qt6ct, and nwg-look.

### Screensharing troubleshooting
https://wiki.hyprland.org/Useful-Utilities/Hyprland-desktop-portal/

https://wiki.hyprland.org/Useful-Utilities/Screen-Sharing/

Make sure to consult both pages.

## MISC
### Automounting drives on startup
If drive is mounted as read only on a dual-boot machine, it might be because of 'Fast Boot' enabled in bios, causing Windows to keep the drive busy.

My `/etc/fstab` entry (Drive ID can be located with `lsblk -f`:
```
# /dev/sdc2
UUID=<DRIVE ID>   /mnt/storage    ntfs-3g     defaults,umask=000,dmask=027,fmask=137,uid=1000,gid=998 0 0
```

### VPN (PIA)
1. Install from AUR: `yay -S piavpn-bin`
2. Start daemon `sudo systemctl start piavpn.service`
3. Enable on startup `sudo systemctl enable piavpn.service`

### Discord
1. `yay -S discord_arch_electron`  
    * OR `pacman -S discord` for non-electron.
2. `yay -S betterdiscordctl-git` and install with `betterdiscordctl-git install` and apply theme in Discord.

### Managing dotfiles
https://www.chezmoi.io/

### Dash
1. install dash `p -S dash`
2. symlink `ln -sfT dash /usr/bin/sh`
3. Create a pacman hook at /etc/pacman.d/hooks/dash.hook containing the following:
```
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = bash

[Action]
Description = Re-pointing /bin/sh symlink to dash...
When = PostTransaction
Exec = /usr/bin/ln -sfT dash /usr/bin/sh
Depends = dash
```
You can check the symlink with `ls -l /bin/sh`

### VS Code git extension
#### (Needs to be tested on Wayland/Hyprland)
https://code.visualstudio.com/docs/editor/settings-sync#_troubleshooting-keychain-issues  
https://wiki.archlinux.org/title/GNOME/Keyring#Using_the_keyring  

Can use runtime arguments with gnome-keyring, but maybe there is a better way.

### Steam
1. Enable multilib repo in `/etc/pacman.conf/`, remember to uncomment both lines.
2. Run `sudo pacman -Syy`
3. Install steam `sudo pacman -S steam` with the appropriate vulkan driver.
4. enable en_US locale `sudo nvim /etc/locale.gen`
5. run `sudo locale-gen`
6. Make a directory for Microsoft fonts `mkdir /usr/share/fonts/WindowsFonts`
7. Copy the fonts from a Windows partition mounted @/mnt `sudo cp /mnt/Windows/Fonts/* /usr/share/fonts/WindowsFonts/`
8. `sudo chmod 644 /usr/share/fonts/WindowsFonts/*`
9. Regen fontconfig cache `fc-cache --force`

### Fonts
Some symbols and fonts might need to have windows fonts installed (e.g. vscode symbolic link indicator). Do it with installation medium.

instructions: [Microsoft fonts](https://wiki.archlinux.org/title/Microsoft_fonts)

### Thunderbird uni mail setup
#### Needs VPN for uni acc
* Name: NAME
* Email: Actual email people see (not username)

* Your login: username (without @)

* -> Manual configuration -> follow instructions on uni site with username (without @)
Authentication method is normal password (might have to change in smtp server settings after logging in)
(VPN needed for uni mail now)

## Colors
### List of places colors are modified
* dwm
* dwmblocks
* gtk / qt
* rofi
* dunst
* wezterm
* bat
* nvim

## Laptop specific
### Accelerometer support
`pacman -S iio-sensor-proxy`
This should make the keyboard activate and deactivate properly from tablet to PC mode!

### Pinch zoom
edit `/etc/security/pam_env.conf` and add `MOZ_USE_XINPUT2 DEFAULT=1` at the bottom. Is not needed for Wayland (Hyprland)

### Bluetooth
1. Install `bluez bluez-utils`.
2. `systemctl start/enable bluetooth.service`.
3. start `bluetoothctl` interactive command. `help` for list of available commands.
4. Enter `power on`, default off and will turn off again on reboot.
5. Discovery mode `scan on`.
6. Enter `devices` to get the MAC addresses of the device you want to connect to.
7. Turn the agent on with `agent on`
8. Enter `pair MAC_address`.
9. Enter `trust MAC_address`.
10. Enter `connect MAC_address`.
You might have to delete the device and re-pair/trust and connect for it to be reckognized as a sound device.

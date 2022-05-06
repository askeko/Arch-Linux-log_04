# Post installation

### The install script
After following the steps in the [installation guide](https://github.com/absentia-gh/artix-linux-log/blob/main/installation.md).
1. curl -LO https://raw.githubusercontent.com/askeko/AARBS/main/aarbs.sh
2. sh aarbs.sh

### If startx
The keyboard layout will by default be set to US (you can check options with `setxkbmap -print -verbose 10`), to change this use the following command: `setxkbmap -model pc105 -layout dk`.
To make it persistent create or modify the file `/etc/X11/xorg.conf.d/00-keyboard.conf` and input:
```
Section "InputClass"
     Identifier "system-keyboard"
     MatchIsKeyboard "on"
     Option "XkbLayout" "dk"
     Option "XkbModel" "pc105"
EndSection
```

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
### Razer mouse support
Packages:
```
pacman -S linux-headers
yay -S openrazer-meta
yay -S razergenie
```


### Automounting drives on startup
If drive is mounted as read only on a dual-boot machine, it might be because of 'Fast Boot' enabled in bios, causing Windows to keep the drive busy.

My fstab entry:
```
# /dev/sdc2
UUID=<DRIVE ID>   /mnt/storage    ntfs-3g     defaults,umask=000,dmask=027,fmask=137,uid=1000,gid=998 0 0
```

### Nvidia drivers
Packages: `pacman -S nvidia nvidia-settings`
Make sure to reboot after installing the drivers.
Sudo into nvidia-settings and check both `Force Composition Pipeline` and `Force Full Composition Pipeline` if you experience screen tearing. Save to X configuration file. You may have to manually create the file `touch /etc/X11/xorg.conf` first.
```
sudo nvidia-settings
```
Save to `/etc/X11/xorg.conf`.

#### Nvidia mouse/UI fix
The proprietary nvidia drivers seem to mess up mouse and UI scaling in a weird way. It only seems to occur when one monitor is landscape and the other is portrait. I've done a few things to fix this:
1. In `/etc/X11/xorg.conf` enter the following under the `Screen` or `Device` section: `Option              "DPI" "96 x 96"`.
2. Uncomment the `xrdb` command in `~/.config/x11/xprofile`.
3. Add `Xcursor.size: 16` to `~/.config/x11/xresources`. >>>>>> This seems to work? <<<<<<<
4. Maybe adding `xrandr --dpi 96` to the beginning of `~/.config/x11/xprofile` is enough?

### VPN (PIA)
1. Install from AUR: `yay -S piavpn-bin`.
2. Start daemon `sudo systemctl start piavpn.service`
3. Enable on startup `sudo systemctl enable piavpn.service`

### Bitwarden
`pacman -S bitwarden`

### Discord
1. `yay -S discord_arch_electron`  
    * OR `pacman -S discord` for non-electron.
2. `yay -S betterdiscordctl-git` and install with `betterdiscordctl-git install` and apply theme in Discord.

### Managing dotfiles
https://www.atlassian.com/git/tutorials/dotfiles

## Fixing system freeze (AMD specific)
Things to try:

1. Run another browser than Firefox (Not tested)
2. https://gist.github.com/wmealing/2dd2b543c4d3cff6cab7 AND https://bbs.archlinux.org/viewtopic.php?id=265239 (CURRENT: Disabled C-states in BIOS) >>> FIXED <<<

### Dash
1. install dash 'p -S dash'
2. symlink 'ln -sfT dash /usr/bin/sh'
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
https://code.visualstudio.com/docs/editor/settings-sync#_troubleshooting-keychain-issues
https://wiki.archlinux.org/title/GNOME/Keyring#Using_the_keyring  
In order to login with GitHub in VS Code, we have to setup the gnome-keyring properly. First make sure the following packages are installed - `gnome-keyring`, `libgnome-keyring` and optionally `seahorse`. Then add the following to `~/.config/x11/xinitrc`:
```
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
```
Because I'm using a console-based login, add the following to `/etc/pam.d/login`: `auth optional pam_gnome_keyring.so` at the end of the `auth` section and `session optional pam_gnome_keyring.so auto_start` at the end of the `session` section.

A restart, not just relog, might be required.

### VS Code settings import
Get the Settings Sync extention, log in with git and import with `Shift + Alt + D`

### Mopidy with Spotify

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

### Lutris

### Calcurse with Google Calendar

### Email (Neomutt?)

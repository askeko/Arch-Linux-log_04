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
### Nvidia drivers
Packages: `pacman -S nvidia nvidia-settings`
Make sure to reboot after installing the drivers.
Sudo into nvidia-settings and check both `Force Composition Pipeline` and `Force Full Composition Pipeline` if you experience screen tearing. Save to X configuration file. You may have to manually create the file `touch /etc/X11/xorg.conf` first.
```
sudo nvidia-settings
```
Save to `/etc/X11/xorg.conf`.

#### Nvidia mouse/UI fix
The proprietary nvidia drivers seem to mess up mouse and UI scaling in a weird way. I've done a few things to fix this:
1. In `/etc/X11/xorg.conf` enter the following under the `Screen` or `Device` section: `Option              "DPI" "96 x 96"`.
2. Uncomment the `xrdb` command in `~/.config/x11/xprofile`.
3. Add `Xcursor.size: 16` to `~/.config/x11/xresources`.
4. Maybe adding `xrandr --dpi 96` to the beginning of `~/.config/x11/xprofile` is enough?

### VPN (PIA)
1. Install from AUR: `yay -S piavpn-bin`.
2. Start daemon `sudo systemctl start piavpn.service`
3. Enable on startup `sudo systemctl enable piavpn.service`

### Bitwarden
`pacman -S bitwarden`

### Discord
`yay -S discord_arch_electron`

### Managing dotfiles
https://www.atlassian.com/git/tutorials/dotfiles

## Fixing system freeze (AMD specific)
Things to try:

1. Run another browser than Firefox (Not tested)
2. https://gist.github.com/wmealing/2dd2b543c4d3cff6cab7 AND https://bbs.archlinux.org/viewtopic.php?id=265239 (CURRENT: Disabled C-states in BIOS) >>> FIXED <<<

### Mouse theme

### Mopidy with Spotify

### Steam
1. Enable multilib repo in `/etc/pacman.conf/`, remember to uncomment both lines.
2. Run `sudo pacman -Syy`
3. Install steam `sudo pacman -S steam` with the appropriate vulkan driver.
4. Make a directory for Microsoft fonts `mkdir /usr/share/fonts/WindowsFonts`
5. 

### Calcurse with Google Calendar

### Email (Neomutt?)

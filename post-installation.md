# Post installation

### The install script
After following the steps in the [installation guide](https://github.com/absentia-gh/artix-linux-log/blob/main/installation.md).
1. Install git: `pacman -S git`.
2. Clone the repo: `git clone https://github.com/absentia-gh/AARBS`.
3. Copy the script: `cp ~/AARBS/aarbs.sh ~/aarbs.sh`.
4. Clean up: `rm -rf AARBS`.
5. Run the script: `sh aarbs.sh`.

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
4. Maybe adding `xrandr --dpi 96` to the beginning of `~/.config/x11/xresources` is enough?

### VPN (PIA)
`yay -S piavpn-bin`

### Bitwarden
`pacman -S bitwarden`

### Razer lighting support
`yay -S openrazer-meta razergenie`
Devices does not show atm.

### TeX typesetting system
`pacman -S texlive-most`

### Discord
`yay -S discord_arch_electron`

### Managing dotfiles
https://www.atlassian.com/git/tutorials/dotfiles

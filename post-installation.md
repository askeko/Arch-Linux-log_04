# Post installation

<!--toc:start-->
- [Post installation](#post-installation)
  - [ToDo](#todo)
    - [absrice-dwm](#absrice-dwm)
    - [absrice-wayland](#absrice-wayland)
    - [Longterm Improvements](#longterm-improvements)
  - [Install Script](#install-script)
    - [Extras](#extras)
    - [Importing Dotfiles](#importing-dotfiles)
  - [Xorg](#xorg)
    - [BSPWM](#bspwm)
    - [Mouse Acceleration](#mouse-acceleration)
    - [Nvidia Drivers](#nvidia-drivers)
    - [Cursor Theme Fix For Polybar](#cursor-theme-fix-for-polybar)
      - [Nvidia Mouse and UI Scaling Fix](#nvidia-mouse-and-ui-scaling-fix)
    - [Integrated AMD GPU and Screen Tearing Fix](#integrated-amd-gpu-and-screen-tearing-fix)
    - [Screen Brightness](#screen-brightness)
  - [Wayland](#wayland)
    - [Theming](#theming)
    - [Screensharing Troubleshooting](#screensharing-troubleshooting)
  - [MISC](#misc)
    - [Automounting Drives On Startup (Deprecated)](#automounting-drives-on-startup-deprecated)
    - [VPN (PIA)](#vpn-pia)
    - [Dash](#dash)
    - [VS Code Git Extension](#vs-code-git-extension)
    - [Fonts](#fonts)
  - [Colors](#colors)
    - [List of Places Colors Are Modified](#list-of-places-colors-are-modified)
      - [dwm colors](#dwm-colors)
      - [wayland colors](#wayland-colors)
      - [Shared colors](#shared-colors)
  - [Laptop Specific](#laptop-specific)
    - [Accelerometer Support](#accelerometer-support)
    - [Pinch Zoom](#pinch-zoom)
    - [Bluetooth (Deprecated)](#bluetooth-deprecated)
<!--toc:end-->

[Installation Guide]: https://github.com/askeko/Arch-Linux-log_04/blob/main/installation.md
[Hyprland Desktop Portal]: https://wiki.hyprland.org/Useful-Utilities/Hyprland-desktop-portal/
[Hyprland Screen-Sharing]: https://wiki.hyprland.org/Useful-Utilities/Screen-Sharing/
[VS Code Keychain]: https://code.visualstudio.com/docs/editor/settings-sync#_troubleshooting-keychain-issues
[Gnome Keyring]: https://wiki.archlinux.org/title/GNOME/Keyring#Using_the_keyring
[Microsoft Fonts]: https://wiki.archlinux.org/title/Microsoft_fonts

## ToDo

### absrice-dwm

- colorscheme to rose pine
- remember rose pine cursor

### absrice-wayland

### Longterm Improvements

- Look through documentation of lf (shared)
- Picom config (X, bspwm)
- Rofi look
- Find a way to hide polybay (and resize windows)

## Install Script

After following the steps in the [installation guide][Installation Guide] and logging in as root:

```sh
# dwm
curl -LO https://raw.githubusercontent.com/askeko/AARBS-xorg/main/aarbs.sh
```

```sh
# wayland
curl -LO https://raw.githubusercontent.com/askeko/AARBS-wayland/main/aarbs.sh
```

Run script:

```sh
sh aarbs.sh
```

### Extras

after logging in, to install some extra dependencies for the system:

```sh
curl -LO https://raw.githubusercontent.com/askeko/Arch-Linux-log_04/main/extras.sh
sh extras.sh
```

This installs the following:

Install Rust: `rustup default stable`

Install NVM+Node: [nvm](https://github.com/nvm-sh/nvm)

### Importing Dotfiles

After running the script, simply run the following command to import all my dotfiles:

```sh
# dwm
chezmoi init --apply https://github.com/askeko/absrice-xorg.git
```

```sh
# wayland
chezmoi init --apply https://github.com/askeko/absrice-wayland.git
```

You might have to rebuild bat cache for the bat theme to work:

```sh
bat cache --build
```

## Xorg

### BSPWM

To allow switching properly between dvorak/qwerty in bspwm using sxhkd, use the
following command to start the daemon

```sh
sxhkd -m -1
```

### Mouse Acceleration

To disable mouse acceleration create the following file:

```sh
/etc/X11/xorg.conf.d/50-mouse-acceleration.conf
-----------------------------------------------
Section "InputClass"
    Identifier "My Mouse"
    MatchIsPointer "yes"
# set the following to 1 1 0 respectively to disable acceleration.
    Option "AccelerationNumerator" "1"
    Option "AccelerationDenominator" "1"
    Option "AccelerationThreshold" "0"
EndSection
```

### Nvidia Drivers

```sh
pacman -S nvidia nvidia-settings
```

Remove `kms` from the `HOOKS` array in `/etc/mkinitcpio.conf` and regenerate the
initramfs with `sudo mkinitcpio -P`. This will prevent the initramfs from
containing the nouveau module making sure the kernel cannot load it during
early boot.

Sudo into nvidia-settings and check both `Force Composition Pipeline` and
`Force Full Composition Pipeline` if you experience screen tearing. Save to X
configuration file. You may have to manually create the file
`touch /etc/X11/xorg.conf` first.

### Cursor Theme Fix For Polybar

Copy the theme folder (in my case `volantes_cursors`) from
`~/.local/share/icons/` to `/usr/share/icons/`.

Edit the file `/usr/share/icons/default/index.theme` with the name of your
theme as shown below:

```sh
[Icon Theme]
Inherits=volantes_cursors
```

#### Nvidia Mouse and UI Scaling Fix

The proprietary nvidia drivers seem to mess up mouse and UI scaling in a weird
way. It only seems to occur when one monitor is landscape and the other is
portrait. I've done a few things to fix this:

In `/etc/X11/xorg.conf` enter the following under the `Screen` or `Device`
section: `Option              "DPI" "96 x 96"`.

Uncomment the `xrdb` command in `~/.config/x11/xprofile`.
Add `Xcursor.size: 16` to `~/.config/x11/xresources`.
**This seems to work?**

Maybe adding `xrandr --dpi 96` to the beginning of `~/.config/x11/xprofile`
is enough?

### Integrated AMD GPU and Screen Tearing Fix

```sh
pacman -S xf86-video-amdgpu
```

```sh
/etc/X11/xorg.conf.d/20-amd-gpu.conf
------------------------------------
Section "Device
    Identifier "AMD Graphics"
    Driver     "amdgpu"
    Option     "TearFree" "true"
EndSection
```

## Wayland

### Theming

Apply GTK/QT themes with qt5ct, qt6ct, and nwg-look.

### Screensharing Troubleshooting

[Hyprland desktop portal][Hyprland Desktop Portal]

[Hyprland screen-sharing][Hyprland Screen-Sharing]

Make sure to consult both pages.

## MISC

### Removing Firefox' tab bar
As I use Tree Style Tabs I don't need the top bar displaying tabs. WARNING: Using TST might cause you to have an excessive number of tabs open at once.  

Navigate to `about:support` and look up "Profile Directory" to see the name of your profile folder 

Edit (or create if non-existing) the following file:

```sh
~/.mozilla/firefox/{$PROFILE}/chrome/userChrome.css
---------------------------------------------------
/* hides the title bar */
#titlebar {
  visibility: collapse;
}

#sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
  display: none;
}
```
Then navigate to `about:config` and change `toolkit.legacyUserProfileCustomizations.stylesheets` to `True`


### Automounting Drives On Startup (Deprecated)

If drive is mounted as read only on a dual-boot machine, it might be because of
'Fast Boot' enabled in bios, causing Windows to keep the drive busy.

My `/etc/fstab` entry (Drive ID can be located with `lsblk -f`:

```sh
# /dev/sdc2
UUID=<DRIVE ID> /mnt/storage ntfs-3g defaults,umask=000,dmask=027,fmask=137,uid=1000,gid=998 0 0
```

### VPN (PIA)

```sh
yay -S piavpn-bin
sudo systemctl start piavpn.service
sudo systemctl enable piavpn.service
```

### Dash

Install dash and symlink:

```sh
pacman -S dash
ln -sfT dash /usr/bin/sh # symlink dash to sh
```

Create the following file to prevent pacman from messing up the symlink:

```sh
/etc/pacman.d/hooks/dash.hook
-----------------------------
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

### VS Code Git Extension

To fix settings sync, consult the following pages:

[Keychain][VS Code Keychain]
[Keyring][Gnome Keyring]

### Fonts

Some symbols and fonts might need to have windows fonts installed
(e.g. vscode symbolic link indicator).

[Instructions][Microsoft Fonts]

## Colors

### List of Places Colors Are Modified

#### dwm colors

- dwm
- dwmblocks

OR
- bspwm
- polybar

#### wayland colors

- hyprland
- waybar

#### Shared colors

- gtk / qt
- dunst
- rofi
- wezterm
- kitty
- vscode
- bat
- nvim
- firefox
- obsidian

## Laptop Specific

### Accelerometer Support

```sh
pacman -S iio-sensor-proxy
```

This should make the keyboard activate and deactivate properly from tablet to
PC mode!

### Pinch Zoom

edit `/etc/security/pam_env.conf` and add `MOZ_USE_XINPUT2 DEFAULT=1` at the
bottom. Is not needed for Wayland (Hyprland)

### Bluetooth

1. Install `bluez bluez-utils blueman`.
2. `systemctl start/enable bluetooth.service`.

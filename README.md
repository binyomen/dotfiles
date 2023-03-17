# dotfiles
Just a place to put my dotfiles

## Setting up a new computer

### Linux

#### The basics

- Install Git from [ppa:git-core/ppa]
- Clone dotfiles (with `git clone --recurse-submodules`) and symlink
  configuration/bins
- Install [brew]
- Install i3, polybar, neovim, fonts-firacode, font-font-awesome,
  build-essential, feh, [fish], and [node]
- Run `updatekitty`
- Install [IDrive]

#### Set up Git

The `~/.gitconfig` file should be as below. Other git configuration files can
just be symlinked.

```gitconfig
[include]
    path = ~/dotfiles/git/gitconfig
[user]
    name = Ben Weedon
    email = ben@weedon.email
```

#### Set up kitty

```fish
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator (which kitty) 50
sudo update-alternatives --config x-terminal-emulator
```

#### Set up fish

```bash
chsh -s $(which fish)
```

#### Purge snap and stand-in Firefox on Ubuntu

Follow [How to Install Firefox as a .Deb on Ubuntu 22.04 (Not a Snap)] for the
most part. Slight modifications:

1. Remove the stand-in version of Firefox with `sudo apt-get remove --purge firefox`
2. Remove the snap version of Firefox with `sudo snap remove --purge firefox`
3. Delete the `~/.mozilla/` directory
4. Only then attempt to install firefox from `ppa:mozillateam/ppa`

I’ve had to try this a few times to get it to work sometimes? You’ll know it
works when firenvim works.

#### Set dark theme

Create `~/.config/gtk-3.0/settings.ini` with the contents:

```ini
[Settings]
gtk-application-prefer-dark-theme=1
```

Then run `gsettings set org.gnome.desktop.interface color-scheme prefer-dark`.

See [Dark theme not applying in Nautilus 42.1.1] for more details.

#### Set up touchpad

If on a laptop with a touchpad, create `/etc/X11/xorg.conf.d/99-touchpad.conf`:

```
Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"

        Option "Tapping" "on"
        Option "NaturalScrolling" "on"
EndSection
```

This will allow tapping the touchpad to register (rather than just clicking it)
and will set the scroll direction to be more natural.

#### Set up hibernation

First, make sure the swap file is at least the size of the amount of memory on
the machine. This can be done by following [How do I increase the size of
swapfile without removing it in the terminal?]. To append more bytes to the swap
file, change the value of the `count` parameter to `dd`. For example, `sudo dd
if=/dev/zero of=/swapfile bs=1M count=1K oflag=append conv=notrunc` will append
1GB, and `sudo dd if=/dev/zero of=/swapfile bs=1M count=4K oflag=append
conv=notrunc` will append 4GB.

Next, enable hibernation by following [How to Enable Hibernate Function in
Ubuntu 22.04 LTS], specifically “Enable Hibernate on Swap File” and skipping
“Create Swap File” and “Regenerate initramfs”.

To allow hibernation without sudo, create
`/etc/polkit-1/localauthority/50-local.d/com.0.hibernate.pkla` with the content:

```ini
[Enable hibernation without sudo]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate;org.freedesktop.login1.handle-hibernate-key;org.freedesktop.login1;org.freedesktop.login1.hibernate-multiple-sessions;org.freedesktop.login1.hibernate-ignore-inhibit
ResultActive=yes
```

Finally, if setting up a laptop, follow [How to go automatically from Suspend
into Hibernate?] to automatically switch to hibernate after the laptop lid is
closed for some time. The following two new files should be created (without the
filename comments):

```ini
# /etc/systemd/sleep.conf.d/99-hibernate.conf
[Sleep]
HibernateDelaySec=1h
```

```ini
# /etc/systemd/logind.conf.d/99-hibernate.conf
[Login]
HandleLidSwitch=suspend-then-hibernate
```

<!-- LINKS -->
[node]: https://github.com/nodesource/distributions#installation-instructions
[ppa:git-core/ppa]: https://git-scm.com/download/linux
[IDrive]: https://www.idrivedownloads.com/downloads/linux/download-for-linux/LinuxScripts/IDriveForLinux.zip
[How to Install Firefox as a .Deb on Ubuntu 22.04 (Not a Snap)]: https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
[fish]: https://launchpad.net/~fish-shell/+archive/ubuntu/release-3
[Dark theme not applying in Nautilus 42.1.1]: https://www.reddit.com/r/gnome/comments/ukx8k9/dark_theme_not_applying_in_nautilus_4211/
[Error opening terminal: xterm-kitty]: https://www.reddit.com/r/commandline/comments/prenxh/error_opening_terminal_xtermkitty/
[brew]: https://docs.brew.sh/Homebrew-on-Linux
[How do I increase the size of swapfile without removing it in the terminal?]: https://askubuntu.com/questions/927854/how-do-i-increase-the-size-of-swapfile-without-removing-it-in-the-terminal
[How to Enable Hibernate Function in Ubuntu 22.04 LTS]: https://ubuntuhandbook.org/index.php/2021/08/enable-hibernate-ubuntu-21-10/
[How to go automatically from Suspend into Hibernate?]: https://askubuntu.com/questions/12383/how-to-go-automatically-from-suspend-into-hibernate

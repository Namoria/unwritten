# Unwritten &nbsp; [![bluebuild build badge](https://github.com/namoria/unwritten/actions/workflows/build.yml/badge.svg)](https://github.com/namoria/unwritten/actions/workflows/build.yml)

>[!WARNING]
>**This is a tinkerer’s custom image.**

## Credit
Unwritten is a custom bootc image based on fedora-bootc and tailored to my AMD CPU/GPU desktop. Included are GNOME and Steam and the CachyOS kernel. The _working_ part of this custom image is taken largely from the excellent [**VedaOS**](https://github.com/Lumaeris/vedaos) by **Lumaeris**. I cannot recommend VedaOS more. The _non-working_ part of Unwritten is entirely mine.

## Installation
>[!Important]
>In Unwritten, **`run0`** is used instead of `sudo`. For some commands, you have to run **`run0 sh -c '$your_command$'`**—this is an SELinux issue and will hopefully be resolved in the future; you can also set SELinux to permissive (`setenforce 0`), but I don’t recommend it. Also, if you wish, you can still use `sudo` in a distrobox environment. 

## Installation
* Please install [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) first.
* Then **rebase** to Unwritten, as shown below.

### 1. Pin a safe deployment
> [!TIP]
> It is good practice to pin a working deployment before you rebase to a new remote image source, for example, before switching from `ghcr.io/ublue-os/bazzite-gnome:stable` to `ghcr.io/namoria/namoriaos:latest`.

- First, gather the index numbers of your deployments; they will be shown in round brackets:
```shell
rpm-ostree status -v
```
- Now, choose a deployment that worked well for you, and pin it in GRUB. For example, this will pin the deployment with `(index: 0)`:
```shell  
sudo ostree admin pin 0
```
- If not needed anymore, you can unpin the pinned deployment:
```shell
sudo ostree admin pin --unpin 0
```
> [!IMPORTANT]  
> Remember that the index numbers change with incoming new deployments, and always make sure to use the correct one.
### 2. Rebase to Unwritten
- Rebase to an unsigned Unwritten image to get the proper signing keys:
```shell
sudo bootc switch ghcr.io/namoria/unwritten:latest
```
-  **After rebooting your system, `sudo` is gone. Use **`run0`** or **`run0 sh -c '$your_command$'`** from now on.**
- If you don’t like your Unwritten experience, you can simply make your previous deployment the default one and boot back into it:
```shell
# USE THIS ONLY IF YOU HAVE CHANGED YOUR MIND:
run0 sh -c 'bootc rollback'
```
> [!NOTE]  
> In this use case, you can only use `bootc rollback` effectively, if you **don’t** update your system after you have rebased your system. If you get a second deployment from your new remote image source, a `bootc rollback` will _not_ bring you back to your previous remote image source.
-  Lastly, if you are satisfied, rebase to a _signed_ Unwritten image to finish the installation:
```shell
run0 sh -c 'bootc switch --enforce-container-sigpolicy ghcr.io/namoria/unwritten:latest'
```

### Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

## Post-installation

### Switching to zsh
The easiest way to switch to [Z Shell (zsh)](https://www.zsh.org/) is to edit your profile in GNOME terminal (Ptyxis). The advantage of this is that system files (e.g. `/etc/passwd`) will be left untouched.
* In Ptyxis, click on the hamburger menu > _Preferences_ > _Profiles_ > on the three vertical dots > _Edit..._ > in the section _Shell_ > enable _Use Custom Command_ > and set it to `/usr/bin/zsh --login`.

### Enable atuin
[Atuin](https://github.com/atuinsh/atuin) is the ‘magical shell history’ and its package is included in Unwritten. To make it work, I recommend switching to zsh first. 

* After switching to zsh, add this to `~/.zshr`:

```shell
eval "$(atuin init zsh)"
```
### Install Starship
[Starship](https://starship.rs) is a beautiful shell prompt written in RUST. 

* To install it locally, run:
```shell
curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin
```
* In your `~/.zshr` file, add:
```shell
export PATH="$HOME/.local/bin:$PATH"
eval "$(starship init zsh)"
```

## Troubleshooting
### GDM does not start at boot
If for some reason, at boot, you are stuck with
```
[ OK ] Started gdm.service – GNOME Display Manager
```
enter the TTY by pressing `Ctrl` + `Alt` + `F2` (or `F3`–`F6`) (+, in some cases, `Fn`), and log in as your user. Then, run:
```shell
run0 groupadd -r gdm
run0 systemctl restart gdm
```
You may have to enter the last command twice, or you may have to reboot.

## Links
### These are well made custom images:

- [VedaOS](https://github.com/Lumaeris/vedaos) – Special credit and thanks to Lumaeris!
- [Zirconium](https://github.com/zirconium-dev/zirconium)
- [XeniaOS](https://github.com/XeniaMeraki/XeniaOS) 
- [solarpowered](https://github.com/askpng/solarpowered)
- [MizukiOS](https://github.com/koitorin/MizukiOS)
- [Entire Bootcrew project](https://github.com/bootcrew)

```bash
cosign verify --key cosign.pub ghcr.io/namoria/unwritten
```

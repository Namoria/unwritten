# Unwritten &nbsp; [![bluebuild build badge](https://github.com/namoria/unwritten/actions/workflows/build.yml/badge.svg)](https://github.com/namoria/unwritten/actions/workflows/build.yml)

>[!WARNING]
>**This is a tinkerer’s custom image and it should be avoided like by anyone, as I tend to break things.**

## Credit
Unwritten is a custom bootc image based on fedora-bootc and tailored to my AMD CPU/GPU desktop. Included are GNOME and Steam and the CachyOS kernel. The _working_ part of this custom image is taken largely from the excellent [**VedaOS**](https://github.com/Lumaeris/vedaos) by **Lumaeris**. I cannot recommend VedaOS more. The _non-working_ part of Unwritten is entirely mine.

## Installation
>[!Important]
>In Unwritten, **`run0`** is used instead of `sudo`. For some commands, you have to write **`run0 sh -c '$your_command$'`**; another workaround would be setting SELinux to permissive. Also, if you wish, you can still use `sudo` in a distrobox environment. This is an SELinux issue and will hopefully be resolved in the future.

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
### 2. Rebase
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
## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Troubleshooting
### GDM does not start at boot
If at boot you are stuck with
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
### Go for these images instead of mine:

- [VedaOS](https://github.com/Lumaeris/vedaos) – Special credit and thanks to Lumaeris! I could have never done this by myself from scratch.
- [Zirconium](https://github.com/zirconium-dev/zirconium)
- [XeniaOS](https://github.com/XeniaMeraki/XeniaOS) 
- [solarpowered](https://github.com/askpng/solarpowered)
- [MizukiOS](https://github.com/koitorin/MizukiOS)
- [Entire Bootcrew project](https://github.com/bootcrew)

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/namoria/unwritten
```

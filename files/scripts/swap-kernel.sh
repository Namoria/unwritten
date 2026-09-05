#!/usr/bin/env bash

########################################################
##  swap-kernel.sh – Fedora kernel → CachyOS kernel   ##
########################################################

set -euo pipefail

# Define Fedora kernel packages that need to be swapped.
# If you just swap "kernel*", some packages could be lost, e.g. kernel-tools, kernel-headers, etc.
FEDORA_KERNEL=(
  kernel
  kernel-core
  kernel-modules
  kernel-modules-core
  kernel-modules-extra
  kernel-devel
  kernel-devel-matched
)

###################################
##  1. Delete Fedora kernel      ##
###################################

dnf5 -y remove --no-autoremove $(rpm -qa --qf '%{NAME} ' "${FEDORA_KERNEL[@]}")

# Clean module directory; dnf likes to create leftovers:
rm -rf /usr/lib/modules/*

#############################################################
##  2. Fedora repos: Exclude kernel packages permanently   ##
#############################################################

# Verhindert, dass ein späterer dnf-Schritt im Build – oder ein
# rpm-ostree install auf dem laufenden System – den Fedora-Kernel zurückholt.
# Die Repo-IDs stehen hier explizit: Das Updates-Repo heißt schlicht
# "updates" und wird von einem Muster wie "*fedora*" nicht erfasst.
dnf5 -y config-manager setopt \
  "fedora.exclude=${FEDORA_KERNEL[*]}" \
  "updates.exclude=${FEDORA_KERNEL[*]}" \
  "updates-testing.exclude=${FEDORA_KERNEL[*]}" \
  "updates-archive.exclude=${FEDORA_KERNEL[*]}"

#####################################
##  3. Install CachyOS kernel  ##
#####################################

dnf5 -y copr enable bieszczaders/kernel-cachyos

# Beim Installieren eines Kernel-RPMs ruft kernel-install seine Plugins auf,
# darunter dracut und rpm-ostree. Im Container-Build läuft das nicht sauber,
# und das initramfs entsteht ohnehin später im initramfs-Modul. Die beiden
# Plugins werden deshalb kurz durch leere Platzhalter ersetzt.
# (Bekanntes Muster, u.a. aus Bazzite.)
pushd /usr/lib/kernel/install.d >/dev/null
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install    50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x 05-rpmostree.install 50-dracut.install
popd >/dev/null

# --allowerasing: dnf darf Pakete ersetzen, die mit dem neuen Kernel kollidieren.
# --exclude: kein devel-Paket – es werden keine Module gebaut (kein akmods).
dnf5 -y install --allowerasing --exclude='kernel-cachyos-devel*' kernel-cachyos

# Platzhalter wieder gegen die echten Plugins tauschen.
pushd /usr/lib/kernel/install.d >/dev/null
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak    50-dracut.install
popd >/dev/null

#####################################
##  4. sched-ext-Scheduler (scx)    ##
#####################################

# Die scx-Scheduler sind der eigentliche Grund für den CachyOS-Kernel.
# Hier nur die Installation – aktiviert (scx_loader.service) und konfiguriert
# (/etc/scx_loader.toml) wird im Recipe.
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
dnf5 -y install scx-scheds scx-tools-git

#####################################
##  5. Cleanup                     ##
#####################################

# COPR-Repos komplett entfernen statt nur deaktivieren, damit keine
# Repo-Dateien im Image zurückbleiben.
dnf5 -y copr remove bieszczaders/kernel-cachyos
dnf5 -y copr remove bieszczaders/kernel-cachyos-addons

#####################################
##  6. Control                     ##
#####################################

# Lieber hier laut scheitern als ein kaputtes Image bauen.

# Genau ein Modulverzeichnis = genau ein Kernel.
if [ "$(ls -1 /usr/lib/modules | wc -l)" -ne 1 ]; then
  echo "swap-kernel.sh: erwartet genau einen Kernel in /usr/lib/modules, gefunden:" >&2
  ls -1 /usr/lib/modules >&2
  exit 1
fi

# Der CachyOS-Kernel ist da.
rpm -q kernel-cachyos >/dev/null

# Fedora-Kernel und devel-Paket sind es nicht.
leftover="$(rpm -qa --qf '%{NAME}\n' kernel-core kernel-cachyos-devel)"
if [ -n "${leftover}" ]; then
  echo "swap-kernel.sh: unerwartete Pakete installiert: ${leftover}" >&2
  exit 1
fi

echo "swap-kernel.sh: OK – Kernel $(ls /usr/lib/modules)"

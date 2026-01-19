# Install Proton VPN app:

wget "https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm"
dnf5 install -y ./protonvpn-stable-*.rpm && dnf makecache --refresh
# `proton-vpn-gnome-desktop` will try to run a postcript to enable its systemd service; we will deny this by setting `noscript`,
# and enable the service manually on the client-side (see README.md):
dnf5 install -y proton-vpn-gnome-desktop --setopt=tsflags=noscripts
rm protonvpn-*.rpm

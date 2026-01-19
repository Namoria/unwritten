#!/bin/bash
# For more info on removing `sudo`, see the « Sudon’t » approach of Vanilla OS.
set -ouex pipefail

dnf5 remove -y --setopt=protected_packages= sudo sudo-python-plugin
rm -f /usr/bin/sudo /usr/bin/pkexec /usr/bin/su

dnf5 clean all

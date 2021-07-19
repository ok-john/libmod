#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

declare -a DEPS=(
                  "apt-utils"
                  "gcc"
                  "pkg-config"
                  "openssl"
                  "libcrypto++6-dbg"
                  "libcrypto++6-dbg"
                  "libcrypto++-utils"
                  "libcrypto++-dev"
                  "libcrypto++-doc"
                  "curl"
                  "git"
                  "kmod"
                  "ca-certificates"
                  "crypto-policies"
                  "make"
                  "flex"
                  "util-linux"
                  "binutils"
                  "libssl1.1"
                  "linux-headers-$(uname -r)"
                  "bc"
                  "bison"
                  "perl"
                  "breathe-doc"
                  "udev"
                  "squashfs-tools"
                  "trace-cmd"
                  "keyutils"
                  "efibootmgr"
                  "mokutil"
                  "pstree"
                  "losetup"
                )

apt install -y ${DEPS[@]} &>/dev/null
apt update -y &>/dev/null
apt upgrade -y &>/dev/null
apt autoremove -y &>/dev/null

echo -e "\n" && echo &>/dev/null

exit 0

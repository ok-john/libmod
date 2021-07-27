#!/bin/bash

if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" exit 1; fi

declare -a DEPS=(
                  "apt-utils"
                  "gcc"
                  "prctl"
                  "libcap-ng-utils"
                  "pkg-config"
                  "openssl"
                  "software-properties-common"
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
                )

apt install -y ${DEPS[@]} 
apt update -y 
apt upgrade -y 
apt autoremove -y

exit 0

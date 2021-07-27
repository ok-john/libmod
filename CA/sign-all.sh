#!/bin/sh
export __dir=$(dirname "$(realpath $0)") && cd $__dir
readonly hash_algo='sha256'
readonly key='sbs.key'
readonly x509='sbs.der'

readonly name="$(basename $0)"
readonly esc='\\e'
readonly reset="${esc}[0m"

green() { local string="${1}"; echo "${esc}[32m${string}${reset}"; }
blue() { local string="${1}"; echo "${esc}[34m${string}${reset}"; }
log() { local string="${1}"; echo "[$(blue $name)] ${string}"; }

alias sign-file="/lib/modules/$(uname -r)/build/scripts/sign-file"

[ -z "${KBUILD_SIGN_PIN}" ] && read -p "Passphrase for ${key}: " KBUILD_SIGN_PIN
export KBUILD_SIGN_PIN

for module in $(dirname $(modinfo -n ))/*.ko; do
  log "Signing $(green ${module})..."
  sign-file "${hash_algo}" "${key}" "${x509}" "${module}"
done

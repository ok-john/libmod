#!/bin/bash
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root" exit 1; fi
readonly __dir=$(dirname "$(realpath $0)") && cd $__dir
readonly __kkey="/usr/src/linux-hwe-5.*-headers-*.*.*-*/certs/signing_key.x509"
readonly __trust_chain="$__dir/certs/fullchain.pem"
if [ $? -ne 0 ]; then exit 0; fi

openssl ecparam -list_curves | tr -s " " | sed "s/: /::/g" | sed "s/ ::/::/g" | tr -s "\n\t\r" | tr -d " \t" | jq -R 'split("::") | { (.[0]): .[1] }' | jq -s '{ "curves": . }'
openssl dgst --list | sed "s/Supported digests://g" | tr -d "\n" | tr -s " " | jq -R '{ "digests": split(" ")[:-1] }'

openssl ec -in $__kkey -text
openssl x509 -in certs/bridge.crt -text -noout

function exists
{
    cat 
}

function pop
{
   cat $_
}

function push
{
   echo "$1" > $_
}

function __dir
{
    echo "$1" 
}


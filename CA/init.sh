#!/bin/bash
#
# Creates Root and Intermediate certificates
#

export __dir=$(dirname "$(realpath $0)") && cd $__dir && rm -rf .fifo.*
export ENV="$__dir"
if [ $? -ne 0 ]; then exit 0; fi
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

__="$__dir/.fifo.$RANDOM" && mkfifo "$__"
_in="$__dir/.fifo.$RANDOM" && mkfifo "$_in"
_out="$__dir/.fifo.$RANDOM" && mkfifo "$_out"
dir="certs" && mkdir -p certs

ca_name=${1:-"ca"}
interm_name=${2:-"bridge"}
sbs_name=${3:-"sbs"}
curve=${4:-"secp521r1"}
digest=${4:-"sha256"}

# relative paths for the root certificate authority
root_ca_pk="$dir/$ca_name.key"
root_ca_cert="$dir/$ca_name.crt"
root_ca_csr="$dir/$ca_name.csr"
root_ca_cnf="cfg.$ca_name.cnf"

# relative paths for the intermediate certificate authority
interm_ca_pk="$dir/$interm_name.key"
interm_ca_cert="$dir/$interm_name.crt"
interm_ca_csr="$dir/$interm_name.csr"
interm_ca_cnf="cfg.$interm_name.cnf"

# relative paths for the intermediate certificate authority
sbs_ca_pk="$dir/$sbs_name.key"
sbs_ca_mok="$dir/$sbs_name.MOK"
sbs_ca_cert="$dir/$sbs_name.crt"
sbs_ca_csr="$dir/$sbs_name.csr"
sbs_ca_cnf="cfg.$sbs_name.cnf"

# Chain of trust output
ca_trust_chain="$dir/fullchain.pem"

# Number of days that the certificates are valid; 840 is my suggested upper bound
valid_length=540

# A json object with all openssl's elliptic cures
export all_openssl_curves="$(openssl ecparam -list_curves |  tr -d " \t\r" | jq -R 'split(":")[0]' | jq -s ' { "curves": . }')"
export all_openssl_digests="$(openssl dgst -list | tr -d " \t\r\n" | jq -R 'split(":")[1] | { "digests": split("-")[1:] }')"

echo -e "\n\nrunning from:\n\t$__dir\nas:\n\t$(id)"

#       -       -       -       -       -       -       -
#
# ROOT CA CREATION
#
openssl ecparam -out $root_ca_pk -name $curve -genkey 
openssl req -config $root_ca_cnf -new -$digest -key $root_ca_pk -out $root_ca_csr
openssl x509 -req -$digest -days $valid_length -in $root_ca_csr -signkey $root_ca_pk -trustout -out $root_ca_cert


# # Use our private key to generate the root certificate authority cert
# openssl req -config $root_ca_cnf x509 -sha512 -days $valid_length -in $root_ca_csr -signkey $root_ca_pk -out $root_ca_cert

#       -       -       -       -       -       -       -
#
# INTERMEDIATE CA CREATION
#
openssl ecparam -out $interm_ca_pk -name $curve -genkey
openssl req -new -config $interm_ca_cnf  -$digest -key $interm_ca_pk -out $interm_ca_csr
openssl x509 -req -$digest -in $interm_ca_csr -days $valid_length -CA $root_ca_cert -CAkey $root_ca_pk -CAcreateserial -trustout -out $interm_ca_cert

cat $interm_ca_cert $root_ca_cert > $ca_trust_chain && chmod 444 $ca_trust_chain

#       -       -       -       -       -       -       -
# SBS GENERATION
openssl req -config $sbs_ca_cnf -new -x509 -newkey rsa:4096 -nodes -days 36500 -outform DER -keyout $sbs_ca_pk -out $sbs_ca_mok

rm -rf .fifo*

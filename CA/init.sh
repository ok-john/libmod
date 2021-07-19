#!/bin/bash
#
# Creates Root and Intermediate certificates
#

# The elliptic curve to use; 
# If changed, I suggest using a curve that maintains TLS 1.3 compatability
# https://datatracker.ietf.org/doc/html/rfc8446#section-4.2.7
curve="secp521r1"

# relative paths for the root certificate authority
root_ca_pk="ca.key"
root_ca_cert="ca.cert"
root_ca_csr="ca.csr"

# relative paths for the intermediate certificate authority
interm_ca_pk="interm.ca.key"
interm_ca_cert="interm.ca.cert"
interm_ca_csr="interm.ca.csr"

# Number of days that the certificates are valid; 840 is my suggested upper bound
valid_length=540

# Formats a JSON blob with all the available ellipitic curves
all_openssl_curves="$(openssl ecparam -list_curves |  tr -d " \t\r" | jq -R 'split(":")[0]' | jq -s ' { "curves": . }')"

#       -       -       -       -       -       -       -
#
# ROOT CA CREATION
#
# Create the root certificate authorities private key
openssl ecparam -out $root_ca_pk -name $curve -genkey

# Use our private key to generate a certificate signing request
openssl req -new -sha512 -key $root_ca_pk -out $root_ca_csr

# Use our private key to generate the root certificate authority cert
openssl x509 -req -sha512 -days $valid_length -in $root_ca_csr -signkey $root_ca_pk -out $root_ca_cert

#       -       -       -       -       -       -       -
#
# INTERMEDIATE CA CREATION
#
# Same process we followed for the root CA
openssl ecparam -out $interm_ca_pk -name $curve -genkey
openssl req -new -sha512 -key $interm_ca_pk -out $interm_ca_csr

# Here we generate a certificate that's signed by the root CA.
openssl x509 -req -in $interm_ca_csr -CA $root_ca_cert -CAkey $root_ca_pk -CAcreateserial -out $interm_ca_cert -days $valid_length -sha512

# Verify the intermediate CA was created properly
openssl x509 -in $interm_ca_cert -text -noout

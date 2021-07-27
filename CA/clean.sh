#!/bin/bash
#
# Removes all key & certificate related file types in the directory that this script exists in (not the relative executing directory)
#
__dir=$(dirname "$(realpath $0)") && cd $__dir
rm -rf .fifo.* *.crt *.csr *.key *.der *.priv *.pem certs/*

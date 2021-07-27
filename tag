#!/bin/bash
if [[ $EUID -eq 0 ]]; then echo "This script must not be run as root" && exit 1; fi
readonly __dir=$(dirname "$(realpath $0)") && cd $__dir
readonly VTAG="$__dir/.tag";
readonly MVAR="$VTAG/MVAR";
readonly MNOR="$VTAG/MNOR";
readonly RLSE="$VTAG/RLSE";

function ensure_euid
{
        if [[ $EUID -ne 0 ]]; then echo -e "This function must be run as root, you're\n\t$(id)" && exit 1; fi
}

function v
{
    if [ -d "$VTAG" ]; then
        echo "v$(cat $MVAR).$(cat $MNOR).$(cat $RLSE)"
    fi
}
function __init
{
    if ! [ -d "$VTAG" ]; then
        mkdir -p $VTAG
        echo 0 > $MVAR
        echo 0 > $MNOR
        echo 0 > $RLSE
    fi
}
function ins
{
    
    chmod 755 $0 && ls $0
}
function clear
{
    rm -rf $VTAG
}
function curb
{
    git branch --list | grep "* " | tr -d " *"
}

function incr 
{
    _vf=${1:-"$RLSE"}
    i=$(cat $_vf)
    i=$(($((i))+1))
    echo $i > $RLSE
    v && exit 0
}
function decr
{
     _vf=${1:-"$RLSE"}
    i=$(cat $_vf)
    i=$(($((i))-1))
    echo $i > $_vf
    v && exit 0
}
function update
{
    local __vers="$(v)"
    local __devb="dev-$__vers"
    git fetch remote origin
    git push --delete origin $__devb
    git tag $__vers
    git push --tags
}
function new-dev
{   
    local _vrs="$(v)"
    local _db="dev-$_vrs"
    local _tg="$vrs/dev"
    git checkout -b $_db
    git add . && git commit -m "init-$_vrs" && git pull --rebase
    git tag $_tg
    git push --set-upstream origin $_db
    git push --tags
}
function uc
{
    git add . && git commit -m "$(v)-$RANDOM" && git pull --rebase && git push && git push --tags
}

__init && ${1:-"v"}

#!/bin/bash
if [[ $EUID -eq 0 ]]; then echo "This script must not be run as root" && exit 1; fi
readonly __dir=$(dirname "$(realpath $0)") && cd $__dir
readonly VTAG="$__dir/.tag";
readonly MVAR="$VTAG/MVAR";
readonly MNOR="$VTAG/MNOR";
readonly RLSE="$VTAG/RLSE";

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

function incr 
{
    _vf=${1:-"$RLSE"}
    i=$(cat $_vf)
    i=$(($((i))+1))
    echo $i > $_vf
    v && exit $i
}

function decr 
{
    _vf=${1:-"$RLSE"}
    i=$(cat $_vf)
    i=$(($((i))-1))
    echo $i > $_vf
    v && exit $i
}

function incm
{
    incr $MNOR
}

function decm
{
    decr $MNOR
}

function incM
{
    incr $MVAR
} 

function decM
{
    decr $MVAR
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

function is_in_remote
{
    local branch=${1}
    local existed_in_remote=$(git ls-remote --heads origin ${branch})

    if [[ -z ${existed_in_remote} ]]; then
        echo 0
    else
        echo 1
    fi
}

function is_in_local {
    local branch=${1}
    local existed_in_local=$(git branch --list ${branch})

    if [[ -z ${existed_in_local} ]]; then
        echo 0
    else
        echo 1
    fi
}

function it
{   
    local _vrs="$(v)"
    local _in_loc="$(is_in_local $_vrs)"
    local _in_rem="$(is_in_remote $_vrs)"

    git fetch origin --tags
    git checkout -b "dev-$_vrs"
    git add . && git commit -m "$RANDOM-$_vrs"
    git push -u origin "dev-$_vrs"
    git tag "dev/$_vrs" && git push --tags
    
    exit 0
}

__init && ${1:-"v"}


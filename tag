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
# Increment/decrement a version tag
# by default it works on x.x.$RLSE 
#
#   see dec[m/M] && inc[m/M]
#
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
# Increment/Decrement Minor value (x.$MNOR.x)
function incm
{
    incr $MNOR
}
function decm
{
    decr $MNOR
}
# Increment/Decrement Major value ($MVAR.x.x)
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
function new-dev
{   
    local _vrs="$(v)"
    local _db="dev-$_vrs"
    local _tg="$_db"
    local _in_loc="$(is_in_local $_db)"
    local _in_rem="$(is_in_remote $_db)"
    echo $_in_loc
    echo $_in_rem
    # # Branch new repository
    if [[ $_in_loc -ne 1 && $_in_rem -ne 1 ]]; then 
        git add . && git commit -m "pre-init-$_vrs"
        git checkout -b $_db
        git pull --rebase
        git tag $_tg
        git push --set-upstream origin $_db
        git push --tags
        exit 0
    fi
    git checkout $_db
}
function p
{
    git pull --rebase && git push && git push --tags
}
function uc
{
    git add . && git commit -m "$(v)-$RANDOM" && git pull --rebase
}

__init && ${1:-"v"}

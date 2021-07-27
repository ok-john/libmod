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
function deps
{
        ensure_euid && apt install ${DEPS[@]}
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

function is_checked_out
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


function incr 
{
    _vf=${1:-"$RLSE"}
    i=$(cat $_vf)
    i=$(($((i))+1))
    echo $i > $_vf
}
function decr 
{
     _vf=${1:-"$RLSE"}
    i=$(cat $_vf)
    i=$(($((i))-1))

    echo $i > $_vf
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
    local _in_loc="$(is_in_local $_db)"
    local _in_rem="$(is_in_remote $_db)"
    
    # # Branch new repository
    if [[ $_in_loc -eq 1 && $is_in_remote -eq 1 ]]; then 
        git add . && git commit -m "pre-init-$_vrs"
        git checkout -b $_db
        git pull --rebase
        git tag $_tg
        git push --set-upstream origin $_db
        git push --tags
        exit 0
    fi
    
    git checkout $_db
    git pull --rebase            
}
function uc
{
    git add . && git commit -m "$(v)-$RANDOM" && git pull --rebase && git push && git push --tags
}

__init && ${1:-"v"}

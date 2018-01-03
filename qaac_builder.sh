#!/bin/bash
 set -e
 set -u
 set -x

extract_qaac(){
    set -- `curl https://api.github.com/repos/nu774/qaac/releases/latest | jq -r ".assets[].name, .assets[].browser_download_url"`
    qaac_version=${1%.*}
    qaac_zipfile=${1}
    qaac_browser_download_url=${2}
    curl -L -o${qaac_zipfile} "${qaac_browser_download_url}"
    7z e -y -oqaac ${qaac_zipfile} "*/x64/*.*"
}

extract_itunes(){( : ${1:?} ${2:?}
    test -f "${1:?}" && read iTunes64Setup_exe_url < ${1:?}
    test -f "${2:?}" && iTunes64Setup_exe_sha1=${2:?}

    i=0
    while ! sha1sum --check "${iTunes64Setup_exe_sha1}"
    do
        ((i++ < 3)) || exit 2
        curl -L -o iTunes64Setup.exe "${iTunes64Setup_exe_url}"
    done

    7z e -y iTunes64Setup.exe AppleApplicationSupport64.msi
    for f in \
    ASL.dll \
    CoreAudioToolbox.dll \
    CoreFoundation.dll \
    icudt??.dll \
    libdispatch.dll \
    libicuin.dll \
    libicuuc.dll \
    objc.dll \
    pthreadVC2.dll
    do
        case ${f} in
        icudt*.dll)
            f=$(7z l -slt AppleApplicationSupport64.msi | awk '$3 ~ /icudt[0-9][0-9]\.dll/ { gsub("^.*_", "", $3); print $3 }')
            test -n "${f}" || exit 2
        ;;
        esac
        7z e -so AppleApplicationSupport64.msi x64_AppleApplicationSupport_${f} >qaac/${f}
    done
    rm AppleApplicationSupport64.msi
)}

which curl sha1sum 7z jq >/dev/null

test ! -d qaac || rm -r qaac
mkdir qaac

extract_qaac
extract_itunes iTunes64Setup.exe.url iTunes64Setup.exe.sha1

chmod 0644 qaac/*.*

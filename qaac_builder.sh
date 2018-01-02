#!/bin/bash
 set -e
 set -u
 set -x

iTunes_URL=https://secure-appldnld.apple.com/itunes12/091-56359-20171213-EDF2198A-E039-11E7-9A9F-D21A1E4B8CED/iTunes64Setup.exe
iTunes_SHA1=0ac4641beb6c4fd0cbb8348ddeb6d741375b75ea

extract_qaac(){
    set -- `curl https://api.github.com/repos/nu774/qaac/releases/latest | jq -r ".assets[].name, .assets[].browser_download_url"`
    qaac_version=${1%.*}
    qaac_zipfile=${1}
    qaac_browser_download_url=${2}
    curl -L -o${qaac_zipfile} "${qaac_browser_download_url}"
    7z e -y -oqaac ${qaac_zipfile} "*/x64/*.*"
}

extract_itunes(){
    i=0
    while ! sha1sum --check <<!
${iTunes_SHA1} *iTunes64Setup.exe
!
    do
        ((++i < 10)) || exit 2
        curl -L -o iTunes64Setup.exe "${iTunes_URL}"
    done

    7z e -y iTunes64Setup.exe AppleApplicationSupport64.msi
    for f in \
        ASL \
        CoreAudioToolbox \
        CoreFoundation \
        icudt55 \
        libdispatch \
        libicuin \
        libicuuc \
        objc
    do
        7z e -so AppleApplicationSupport64.msi "x64_AppleApplicationSupport_${f}.dll" >qaac/${f}.dll
    done
    rm AppleApplicationSupport64.msi
}

which curl sha1sum 7z jq >/dev/null

test ! -d qaac || rm -r qaac
mkdir qaac

extract_qaac
extract_itunes

chmod 0644 qaac/*.*

#!/bin/bash
#
# Copyright (c) 2013-2014, Kamil Wilas (wilas.pl)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
set -e -E -u -o pipefail; shopt -s failglob; set -o posix; set +o histexpand

RED="\e[1;31m"
NORMAL="\e[0m"
log_error(){
    printf "${RED}[ERROR] %s${NORMAL}\n" "${*}" >&2
}
log_info(){
    printf "[INFO] %s\n" "${*}"
}

# default install location for bins and man
: ${MANDIR:=/usr/local/man/man1}
: ${PREFIX:=/usr/local/bin}

# get info about env. for default settings
BASH_DEFAULT=$(command -v bash || (log_error "bash command not available." && exit 1))
PL_DEFAULT=$(command -v perl || (log_error "perl command not available." && exit 1))

# prepare shebang - from env. or default
: ${BASH_SHEBANG:=${BASH_DEFAULT}}
: ${PL_SHEBANG:=${PL_DEFAULT}}

# install command
INSTALL="install"

# prepare build directory
BUILD_DIR=$(mktemp -d -t 'vbkick_build.XXXXXXXXXX')

# Do you want install or uninstall software, by default install.
: ${UNINSTALL:=0}
# Do you want stable or dev version, by default stable.
: ${STABLE:=1}

# what scripts install/uninstall
BASH_TARGET="vbkick"
PL_TARGET=("vbhttp.pm" "vbtyper.pm")
MAN_TARGET="vbkick.1"

# needed to remove already installed legancy script
PY_TARGET="convert_2_scancode.py"

install_bins(){
    local branch="stable"
    if [[ ${STABLE} -ne 1 ]]; then
        branch="master"
    fi
    mkdir -p "${BUILD_DIR}"
    for file in "${PL_TARGET[@]}"; do
        curl -Lksf "https://raw.githubusercontent.com/wilas/vbkick/${branch}/${file}" -o "${BUILD_DIR}/${file}.curl" ||\
            (log_error "download ${file} bin failed." && return 1)
    done
    curl -Lksf "https://raw.githubusercontent.com/wilas/vbkick/${branch}/${BASH_TARGET}" -o "${BUILD_DIR}/${BASH_TARGET}.curl" ||\
        (log_error "download ${BASH_TARGET} bin failed." && return 1)
    curl -Lksf "https://raw.githubusercontent.com/wilas/vbkick/${branch}/docs/man/${MAN_TARGET}" -o "${BUILD_DIR}/${MAN_TARGET}.curl" ||\
        (log_error "download vbkick man page failed." && return 1)
    for file in "${PL_TARGET[@]}"; do
        sed "1,1 s:#"'!'"/usr/bin/perl:#!${PL_SHEBANG}:; 1,1 s:\"::g" "${BUILD_DIR}/${file}.curl" > "${BUILD_DIR}/${file}.tmp"
    done
    sed "1,1 s:#"'!'"/bin/bash:#!${BASH_SHEBANG}:; 1,1 s:\"::g" "${BUILD_DIR}/${BASH_TARGET}.curl" > "${BUILD_DIR}/${BASH_TARGET}.tmp"
    ${INSTALL} -m 0755 -d "${PREFIX}"
    for file in "${PL_TARGET[@]}"; do
        ${INSTALL} -m 0755 -p "${BUILD_DIR}/${file}.tmp" "${PREFIX}/${file}"
    done
    ${INSTALL} -m 0755 -p "${BUILD_DIR}/${BASH_TARGET}.tmp" "${PREFIX}/${BASH_TARGET}"
    ${INSTALL} -m 0755 -d "${MANDIR}"
    ${INSTALL} -g 0 -o 0 -m 0644 -p "${BUILD_DIR}/${MAN_TARGET}.curl" "${MANDIR}/${MAN_TARGET}"
    rm -rf "${BUILD_DIR}"
}

uninstall_bins(){
    cd "${MANDIR}" && rm -f "${MAN_TARGET}"
    cd "${PREFIX}" && rm -f "${BASH_TARGET}" && rm -f "${PY_TARGET}"
    for file in "${PL_TARGET[@]}"; do
        rm -f "${PREFIX}/${file}"
    done
}

fail_guard(){
    log_error "Install/Uninstall failed."
    # clean BUILD_DIR if exist
    if [[ -d ${BUILD_DIR} ]]; then
        rm -rf ${BUILD_DIR}
    fi
    exit 1
}

trap fail_guard SIGHUP SIGINT SIGTERM ERR
if [[ ${UNINSTALL} -eq 1 ]]; then
    uninstall_bins
    log_info "Uninstall succeeded."
else
    install_bins
    log_info "Install succeeded."
fi

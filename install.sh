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
    printf "${RED}[ERROR] ${*}${NORMAL}\n" >&2
}
log_info(){
    printf "[INFO] ${*}\n"
}

# default install location for bins and man
: ${MANDIR:=/usr/local/man/man1}
: ${PREFIX:=/usr/local/bin}

# get info about env. for default settings
BASH_DEFAULT=$(command -v bash || (log_error "bash command not available." && exit 1))
PY_DEFAULT=$(command -v python || (log_error "python command not available." && exit 1))

# prepare shebang - from env. or default
: ${BASH_SHEBANG:=${BASH_DEFAULT}}
: ${PY_SHEBANG:=${PY_DEFAULT}}

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
PY_TARGET="convert_2_scancode.py"
MAN_TARGET="vbkick.1"

install_bins(){
    local branch="stable"
    if [[ ${STABLE} -ne 1 ]]; then
        branch="master"
    fi
	mkdir -p "${BUILD_DIR}"
    curl -Lksf "https://raw.githubusercontent.com/wilas/vbkick/${branch}/${PY_TARGET}" -o "${BUILD_DIR}/${PY_TARGET}.curl" ||\
        (log_error "download convert_2_scancode.py bin failed." && return 1)
    curl -Lksf "https://raw.githubusercontent.com/wilas/vbkick/${branch}/${BASH_TARGET}" -o "${BUILD_DIR}/${BASH_TARGET}.curl" ||\
        (log_error "download vbkick bin failed." && return 1)
    curl -Lksf "https://raw.githubusercontent.com/wilas/vbkick/${branch}/docs/man/${MAN_TARGET}" -o "${BUILD_DIR}/${MAN_TARGET}.curl" ||\
        (log_error "download vbkick man page failed." && return 1)
	sed "1,1 s:#"'!'"/usr/bin/python:#!${PY_SHEBANG}:; 1,1 s:\"::g" "${BUILD_DIR}/${PY_TARGET}.curl" > "${BUILD_DIR}/${PY_TARGET}.tmp"
	sed "1,1 s:#"'!'"/bin/bash:#!${BASH_SHEBANG}:; 1,1 s:\"::g" "${BUILD_DIR}/${BASH_TARGET}.curl" > "${BUILD_DIR}/${BASH_TARGET}.tmp"
	${INSTALL} -m 0755 -d "${PREFIX}"
	${INSTALL} -m 0755 -p "${BUILD_DIR}/${PY_TARGET}.tmp" "${PREFIX}/${PY_TARGET}"
	${INSTALL} -m 0755 -p "${BUILD_DIR}/${BASH_TARGET}.tmp" "${PREFIX}/${BASH_TARGET}"
	${INSTALL} -m 0755 -d "${MANDIR}"
	${INSTALL} -g 0 -o 0 -m 0644 -p "${BUILD_DIR}/${MAN_TARGET}.curl" "${MANDIR}/${MAN_TARGET}"
	rm -rf "${BUILD_DIR}"
}

uninstall_bins(){
	cd "${PREFIX}" && rm -f "${BASH_TARGET}" && rm -f "${PY_TARGET}"
	cd "${MANDIR}" && rm -f "${MAN_TARGET}"
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

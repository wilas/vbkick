#!/bin/bash
set -e -E -u -o pipefail; shopt -s failglob;

# set environment variables if available
[[ -s "adm_envrc" ]] && . "./adm_envrc"

# Given a new Virtualbox Guest
if [[ $# -ge 1 ]]; then
    context_file="${1}"
else
    context_file="adm_context.txt"
fi

# Each script is separate feature
while read -r script; do
    # don't process comments
    [[ "${script}" =~ ^#.*$ ]] && continue
    if [[ -s "${script}" ]]; then
        # true is used because it's ok when tested command fail
        bash "${script}" || true
    fi
done < "${context_file}"

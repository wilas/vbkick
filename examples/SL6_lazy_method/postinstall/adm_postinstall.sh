#!/bin/bash
set -eEu

# set environment variables if available
[[ -s "adm_envrc" ]] && . "./adm_envrc"

if [[ $# -ge 1 ]]; then
    context_file="${1}"
else
    context_file="adm_context.txt"
fi
while read -r script; do
    # don't process comments
    [[ "${script}" =~ ^#.*$ ]] && continue
    if [[ -s "${script}" ]]; then
        echo "${script}"
        bash "${script}"
    fi
done < "${context_file}"

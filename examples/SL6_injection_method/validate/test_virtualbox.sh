#!/bin/bash

# Feature: Virtualbox Guest Additions
# Given VBoxControl command
which VBoxControl 1>/dev/null 2>&1
[[ $? -ne 0 ]] && { printf "\e[1;31mVBoxControl: FAIL\n\e[0m"; exit 1; }
# When I run "VBoxControl --version" command
VBoxControl --version 1>/dev/null 2>&1
version=$(VBoxControl --version) # e.g. 4.2.12r84980
[[ $? -ne 0 ]] && { printf "\e[1;31mVBoxControl Version: FAIL\n\e[0m"; exit 1; }
version=${version%r*} #e.g. 4.2.12
# Then I expect version is up-to-date
if [[ $version == "${VBOX_VERSION}" ]]; then
    printf "\e[1;32mVirtualbox Guest Additions: OK\n\e[0m";
else
    printf "\e[1;31mVirtualbox Guest Additions: FAIL\n\e[0m";
fi

# Feature: puppet provisioner
# Given puppet command
which puppet 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mpuppet: FAIL\n\e[0m"; exit 1; }
# When I run "puppet --version" command
puppet --version 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mpuppet --version: FAIL\n\e[0m"; exit 1; }
# Then I expect success
printf "\e[1;32mpuppet: OK\n\e[0m";

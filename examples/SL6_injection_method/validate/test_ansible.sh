# Feature: ansible provisioner
# Given ansible command
which ansible 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mansible: FAIL\n\e[0m"; exit 1; }
# When I run "ansible --version" command
ansible --version 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mansible --version: FAIL\n\e[0m"; exit 1; }
# Then I expect success
printf "\e[1;32mansible: OK\n\e[0m";

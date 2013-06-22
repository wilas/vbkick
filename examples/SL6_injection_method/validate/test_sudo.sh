# Feature: sudoers has disabled requiretty
# Given /etc/sudoers file
# When I grep /etc/sudoers file 
sudo cat /etc/sudoers | grep -E "Defaults[ ]+requiretty" | grep -vq "^#"
# Then requiretty is disabled
[ $? -eq 0 ] && { printf "\e[1;31msudo requiretty: FAIL\n\e[0m"; exit 1; }
printf "\e[1;32msudo requiretty: OK\n\e[0m";

# Feature: chef provisioners
# Given chef-client command
which chef-client 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mchef-client: FAIL\n\e[0m"; exit 1; }
# And chef-solo command
which chef-solo 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mchef-solo: FAIL\n\e[0m"; exit 1; }
# When I run "chef-client --version" command
chef-client --version 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mchef-client --version: FAIL\n\e[0m"; exit 1; }
# And I run "chef-solo --version" command
chef-solo --version 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mchef-solo --version: FAIL\n\e[0m"; exit 1; }
# Then I expect success
printf "\e[1;32mchef: OK\n\e[0m";

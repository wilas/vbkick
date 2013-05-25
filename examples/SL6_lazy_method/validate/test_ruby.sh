# Feature: ruby interpreter
# Given ruby command
which ruby 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mruby: FAIL\n\e[0m"; exit 1; }
# When I run "ruby --version" command
ruby --version 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mruby --version: FAIL\n\e[0m"; exit 1; }
# Then I expect success
printf "\e[1;32mruby: OK\n\e[0m";

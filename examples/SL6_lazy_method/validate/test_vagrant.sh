# Feature: vagrant user
# Given vagrant user
id vagrant 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mvagrant user: FAIL\n\e[0m"; exit 1; }
# When I login using ssh key
wget -q -O /tmp/vagrant.pub.tmp --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
diff ~vagrant/.ssh/authorized_keys /tmp/vagrant.pub.tmp 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mvagrant user - ssh key: FAIL\n\e[0m"; exit 1; }
rm -f /tmp/vagrant.pub.tmp
# And I run sudo command
sudo -U vagrant -l | grep -w "may run" 1>/dev/null 2>&1
[ $? -ne 0 ] && { printf "\e[1;31mvagrant user - sudo: FAIL\n\e[0m"; exit 1; }
# Then I expect success
printf "\e[1;32mvagrant user: OK\n\e[0m";

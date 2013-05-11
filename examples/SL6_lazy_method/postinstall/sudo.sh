cp /etc/sudoers /etc/sudoers.orig
# Allow sudo commands without a tty
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

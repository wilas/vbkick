# Vagrant specific
date > /etc/vagrant_box_build_time

# Add vagrant user
/usr/sbin/groupadd vagrant
/usr/sbin/useradd vagrant -g vagrant -G wheel -d /home/vagrant -c 'Vagrant box user'
echo "vagrant" | passwd --stdin vagrant
#echo vagrant:vagrant | /usr/sbin/chpasswd
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant
#echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Installing vagrant keys
mkdir -pm 700 /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' 
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

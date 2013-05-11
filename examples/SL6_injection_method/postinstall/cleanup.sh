# Initial SL system clean-up
yum -y erase wireless-tools gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all
#rm -rf /etc/yum.repos.d/puppetlabs.repo
#rm -rf /etc/yum.repos.d/epel.repo

# Make sure Udev doesn't block our network - http://6.ptmc.org/?p=164
#echo "cleaning up udev rules"
#rm /etc/udev/rules.d/70-persistent-net.rules
#rm -rf /dev/.udev/
#rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Add veewee user - to be honest not needed - just to make veewee happy and pass veewee tests

/usr/sbin/groupadd veewee
/usr/sbin/useradd veewee -g veewee -G wheel
echo "veewee"|passwd --stdin veewee
echo "veewee ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/veewee
chmod 0440 /etc/sudoers.d/veewee
#echo "veewee ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

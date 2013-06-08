# Add vbkick user and group
/usr/sbin/groupadd vbkick
/usr/sbin/useradd vbkick -g vbkick -G wheel -c "vbkick box user"
# set password
echo "vbkick" | passwd --stdin vbkick
# give sudo access (grants all permissions to user vbkick)
echo "vbkick ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vbkick
chmod 0440 /etc/sudoers.d/vbkick
# add vbkick's public key - user can ssh without password
mkdir -pm 700 ~vbkick/.ssh
wget --no-check-certificate https://raw.github.com/wilas/vbkick/master/keys/vbkick_key.pub -O ~vbkick/.ssh/authorized_keys
chmod 0600 ~vbkick/.ssh/authorized_keys
chown -R vbkick:vbkick ~vbkick/.ssh

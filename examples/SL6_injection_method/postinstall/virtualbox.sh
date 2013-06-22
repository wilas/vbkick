# Installing the virtualbox guest additions
# VBoxGuestAdditions iso is attached (by vbkick) to IDE Controller port 1 device 0
mount /dev/sr1 /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

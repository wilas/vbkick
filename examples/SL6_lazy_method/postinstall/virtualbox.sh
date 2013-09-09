# Installing the virtualbox guest additions
# VBoxGuestAdditions iso is attached (by vbkick) to SATA Controller port 1 device 0
if [ -b /dev/sr1 ]; then
    mount /dev/sr1 /mnt
elif [ -b /dev/sr0 ]; then
    mount /dev/sr0 /mnt
else
    exit 1
fi
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

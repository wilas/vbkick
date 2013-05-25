# Examples

Open Source mean freedom – enjoy that freedom and choose best solution for you.

## adm_postinstall.sh - used in both method

Easy way to administer postinstall scripts.
```
adm_context.txt         # list of scrips run by adm_postinstall.sh during postinstall process (order matter), you can also use comments
adm_envrc               # list of env. variables (may be used by all scripts) - help keep important variables in one place, e.g. Virtualbox version
adm_postinstall.sh      # take care about exec other scripts
```

Use adm_postinstall.sh is a convenient manner, but not mandatory.


## injection postinstall method

Run postinstall scripts during kickstarting process in chroot environment.

### Why?

 - no extra users and SSH keys needed to run postinstall scripts (more secure for kickstarting hardware machine, useful for production env. e.g. with PXE)
 - to create easy/automated and tested way to switch/install desktop/OS and check if all needed (for us) apps still works (This is answer for that question: What if the next release breaks something in my applications?)
 - to create easy way for tuning box/PC during installation (tuning.sh as an example) - running puppet manifest, ansible playbooks is just one line :-) (puppet modules, ansible playbooks may be downloaded during kickstarting [if usb_stick then earlier upload to flash disc], git clone is also possible - do what you need)
 - create bootable (auto install) usb stick or os_img.iso with almost same kickstart.cfg and sh scripts as already tested in virtual env. (your PC crash and you need quickly new one with same apps as earlier)

### Good to know

If something fail during installation, e.g puppet was not installed (maybe puppet repo was temporary unavailable) then anyway postinstall process is continued and completed (mean: all sh scripts exec). After runing `vbkick validate VM_NAME` you should realize that puppet was not installed. Next step should be login into box, go into postinstall dir (e.g. cd /var/tmp/postinstall)(dir was already created by kickstart) and run: sh puppet.sh (there is no objection to run that scrip also via SSH).

postinstall_transport and postinstall_launch options are not required in this method.


Use Case flow:
```
vbkick build SL6_inject
vbkick validate SL6_inject
vbkick export SL6_inject

vagrant box add 'SL64_inject' SL6_inject.box
vagrant box list
```

## lazy postinstall method

This method is already used by *Veewee* and *Vagrant*.
Kickstart process create base machine and configure SSH connection (creates user, copy SSH keys, configure sudo, etc.).
Postinstall scripts are later (after machine reboot) transport (via SCP) to already created box and exec there (via SSH).

### Why?
 - to create easy way for tuning box/PC after installation (tuning.sh as an example).
 - to upgrade already existing Virtualbox Guest (e.g. install new GuestAdditions)
 - to create easy/automated and tested way to upgrade desktop/OS and check if everything works

### Good to know

postinstall_transport and postinstall_launch options are required in this method. 
If these options are empty then nothing is run during postinstall.

Use Case flow:
```
vbkick build SL6_lazy
vbkick postinstall SL6_lazy
vbkick validate SL6_lazy
vbkick export SL6_lazy

vagrant box add 'SL64_lazy' SL6_lazy.box
vagrant box list
```

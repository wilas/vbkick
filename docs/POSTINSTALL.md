## Postinstall

There are 2 main postinstall methods:
 - lazy - run postinstall scripts "later" - after installing the OS.
 - injection - run postinstall scripts during kickstarting process in chroot environment (implemented inside the kickstart file).

Of course you can also mix these methods.

Note: If something fail in your postinstall script/command then postinstall process should be terminated - more [#28](../../../issues/28)

### lazy postinstall method

This method is already used by *Veewee* and *Vagrant*.
Kickstart process creates a base machine and configure SSH connection (creates user, copy SSH keys, configure sudo, etc.).
Postinstall scripts are later (after machine reboot) transported (via SCP) to already created box and exec there (via SSH).

postinstall_transport and postinstall_launch parameters in the definition.cfg are required in this method:
```
postinstall_launch=("cd postinstall && sudo bash adm_postinstall.sh")
postinstall_transport=("postinstall")
```

#### Why?

 - easy way for tuning box/PC after installation (tuning.sh as an example)
 - allow run postinstall commands many times (e.g puppet repo is unavailalble, then try later again)
 - works with all Unix/Linux systems
 - allow upgrade already exisiting VM, e.g. install new GuestAdditions, new KDE version, etc. (building the new VM is not needed)
 - easy way to play with already existing vanilla machine and test postinstall scripts before release to production


#### Use Case flow:
```
vbkick build SL6_lazy
vbkick postinstall SL6_lazy
vbkick validate SL6_lazy
vbkick export SL6_lazy

vagrant box add 'SL64_lazy' SL6_lazy.box
vagrant box list
```

### injection postinstall method

Run postinstall scripts during kickstarting process in chroot environment.

postinstall_transport and postinstall_launch options in the definition.cfg are not required in this method:
```
postinstall_launch=("")
postinstall_transport=("")
```
It is ok to remove these options from definition as well, default value from vbkick is exactly the same.

#### Why?

 - no extra users and SSH keys needed to run postinstall scripts (more secure, useful for production env. e.g. with PXE)
 - help creates bootable (auto install) usb stick or os_img.iso with almost same kickstart.cfg and shell scripts as already tested in virtual env. (your PC crash and you need quickly new one with same apps as earlier)
 - cons: may not work for every OS
 - cons: postinstall commands are exec only once, if something fail then you need to build your machine again (may be slow)
 - cons: debugging in chroot env.
 - cons: kickstart_port is setup in 2 places for injection postinstall method: kickstart/kickstart_file.cfg, definition.cfg


#### Use Case flow:
```
vbkick build SL6_inject
vbkick validate SL6_inject
vbkick export SL6_inject

vagrant box add 'SL64_inject' SL6_inject.box
vagrant box list
```

### adm_postinstall.sh

Easy way to administer postinstall scripts.
```
adm_context.txt         # list of scrips run by adm_postinstall.sh during postinstall process (order matter), you can also use comments
adm_context_desktop.txt # another context file
adm_envrc               # list of env. variables (setup for all scripts) - help keeps important variables in one place, e.g. Virtualbox version
adm_postinstall.sh      # take care about exec other scripts
```

Use adm_postinstall.sh is a convenient manner (help reduce number of ssh authentications), but not mandatory.

Simply, you can use below options in definition.cfg

```
postinstall_launch=("cd postinstall && sudo bash adm_postinstall.sh")
postinstall_transport=("postinstall")

or

postinstall_launch=("cd postinstall && sudo bash adm_postinstall.sh adm_context_desktop.txt")
postinstall_transport=("postinstall")
```

instead of

```
postinstall_launch=(
"bash postinstall/basic.sh"
"bash postinstall/ruby.sh"
"bash postinstall/puppet.sh"
"bash postinstall/chef.sh"
"bash postinstall/ansible.sh"
"bash postinstall/virtualbox.sh"
)
postinstall_transport=("postinstall")
```


# Examples - how to customize box definition.

## Typical box definition structure.

```
    .
    └─ SL6
       ├── definition.cfg -> definition-6.4-x86_64.cfg
       ├── definition-6.3-i386.cfg
       ├── definition-6.3-x86_64.cfg
       ├── definition-6.4-i386.cfg
       ├── definition-6.4-x86_64.cfg
       ├── kickstart
       │   └── <scientificlinux-6.4-x86_64-noX.cfg, scientificlinux-6.4-x86_64-GNOME.cfg, ...>
       ├── validate
       │   └── <adm_features.sh, adm_context.txt, adm_envrc, test_puppet.sh, test_ruby.sh, test_virtualbox.sh, test_vagrant, ....sh >
       └── postinstall
           └── <adm_postinstall.sh, adm_context.txt, adm_envrc, base.sh, cleanup.sh, puppet.sh, ruby.sh, virtualbox.sh, ....sh >
```

**The definition.cfg is symlink** to choosen vbkick definition. The definition contains all crucial parameters to build and tuning the new box, e.g.:

 - number of CPUs
 - memory size
 - disk size
 - os type
 - url to install ISO
 - boot sequence
 - ssh key
 - command for clean shutdown
 - list of postinstall commands/scripts
 - list of validation commands/tests

## Example definition.cfg - the core file of each box.

```
    cpu_count=1
    memory_size=512
    disk_size=10140
    disk_format="vdi"
    video_memory_size=10
    hostiocache="on"
    vm_options=("ioapic:on")
    os_type_id="RedHat_64"
    iso_file="SL-64-x86_64-2013-03-18-boot.iso"
    iso_src="http://ftp1.scientificlinux.org/linux/scientific/6.4/x86_64/iso/SL-64-x86_64-2013-03-18-boot.iso"
    iso_sha256="f0ccbd8cb802b489ab6a606c90f05f5d249db1cb1e0e931dbb703240b4d97d8c"
    boot_wait=10
    boot_cmd_sequence=(
        "<Tab> text ks=http://%IP%:%PORT%/kickstart/scientificlinux-6.4-x86_64-lazy_noX.cfg<Enter>"
    )
    kickstart_port=7122
    kickstart_timeout=7200
    ssh_host_port=2222
    ssh_user="vagrant"
    ssh_priv_key="vagrant_key"
    ssh_priv_key_src="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant"
    postinstall_launch=("cd postinstall && sudo -E bash adm_postinstall.sh")
    postinstall_transport=("postinstall")
    validate_launch=("cd validate && bash adm_features.sh")
    validate_transport=("validate")
    clean_transported=0
    shutdown_cmd="sudo /sbin/halt -h -p"
    shutdown_timeout=20
```

## Typical build flow.

creates own definition based on selected template
 - vim definition-6.4-x86_64-my_custom.cfg
 - ln -fs definition-6.4-x86_64-my_custom.cfg definition.cfg

`vbkick build VM_NAME`
 - creates a new VM
 - download install media
 - boot (kickstart) machine and talk to installer using boot_cmd_sequence
 - wait until machine is ready or a timeout is reached

`vbkick postinstall VM_NAME`
 - postinstall configuration - transport posinstall scripts via SCP and exec launch commands via SSH

`vbkick validate VM_NAME`
 - validate the new VM

`vbkick export VM_NAME`
 - export machine as a vagrant box


## Postinstall

There are 2 main postinstall methods:
 - lazy - run postinstall scripts "later" - after installing the OS.
 - injection - run postinstall scripts during kickstarting process in chroot environment (implemented inside the kickstart file),

Of course you can also mix these methods. Postinstall process help answer for this question: What if the next OS release breaks something in my applications?

Open Source mean freedom – enjoy that freedom and choose best solution for you.


### adm_postinstall.sh - used in both postinstall methods

Easy way to administer postinstall scripts.
```
adm_context.txt         # list of scrips run by adm_postinstall.sh during postinstall process (order matter), you can also use comments
adm_envrc               # list of env. variables (may be used by all scripts) - help keep important variables in one place, e.g. Virtualbox version
adm_postinstall.sh      # take care about exec other scripts
```

Use adm_postinstall.sh is a convenient manner, but not mandatory.

Simply, you can use below options in definition.cfg

```
postinstall_launch=("cd postinstall && sudo bash adm_postinstall.sh")
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

### lazy postinstall method

This method is already used by *Veewee* and *Vagrant*.
Kickstart process creates a base machine and configure SSH connection (creates user, copy SSH keys, configure sudo, etc.).
Postinstall scripts are later (after machine reboot) transport (via SCP) to already created box and exec there (via SSH).

postinstall_transport and postinstall_launch parameters in the definition.cfg are required in this method:
```
postinstall_launch=("cd postinstall && sudo bash adm_postinstall.sh")
postinstall_transport=("postinstall")
```

#### Why?

 - easy way for tuning box/PC after installation (tuning.sh as an example)
 - allow run postinstall commands many times (e.g puppet repo is unavailalble, then try later again)
 - works with all Unix/Linux systems
 - allow upgrade already exisiting VM, e.g. install new GuestAdditions, new KDE version, etc. (build new VM is not needed)


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

 - no extra users and SSH keys needed to run postinstall scripts (more secure for kickstarting hardware machine, useful for production env. e.g. with PXE)
 - easy way for tuning box/PC during installation (tuning.sh as an example) - running puppet manifest, ansible playbooks is just one line :-) (puppet modules, ansible playbooks may be downloaded during kickstarting [if usb_stick then earlier upload to flash disc], git clone is also possible - do what you need)
 - help creates bootable (auto install) usb stick or os_img.iso with almost same kickstart.cfg and sh scripts as already tested in virtual env. (your PC crash and you need quickly new one with same apps as earlier)
 - cons: may not work for every OS
 - cons: postinstall commands are exec only once

#### Good to know

If something fail during installation, e.g puppet was not installed (maybe puppet repo was temporary unavailable) then anyway postinstall process is continued and completed (mean: all sh scripts exec). After runing `vbkick validate VM_NAME` you should realize that puppet was not installed. Next step should be login into box, go into postinstall dir (e.g. cd /var/tmp/postinstall)(dir was already created by kickstart) and run: sh puppet.sh (there is no objection to run that scrip also via SSH).


#### Use Case flow:
```
vbkick build SL6_inject
vbkick validate SL6_inject
vbkick export SL6_inject

vagrant box add 'SL64_inject' SL6_inject.box
vagrant box list
```


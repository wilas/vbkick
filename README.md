# Description

Vbkick is a simple bash tool for building and maintaining VirtualBox VMs and Vagrant Base Boxes described as a code in a single definition file (*vbmachine.cfg*). Vbkick is a replacement for [Veewee](https://github.com/jedi4ever/veewee) - you may want to read [why](docs/WHY.md). Vbkick works on Linux, FreeBSD, MacOSX and has [minimal dependencies](docs/REQUIREMENTS.md).

# Getting Started

## Install/Uninstall

Note: GNU make is required to install from git, you may need to install `gmake` on your system.

using git
```
git clone git@github.com:wilas/vbkick.git
# git checkout stable #default (master) branch is for development, if you prefer use more stable version - choose stable branch
sudo make install
sudo make uninstall
```
or advance via git
```
git clone git@github.com:wilas/vbkick.git
# sudo BASH_SHEBANG="/usr/bin/env bash" PL_SHEBANG="/usr/bin/env perl" PREFIX="$HOME/bin" make install
sudo PREFIX="$HOME/bin" make install
sudo PREFIX="$HOME/bin" make uninstall
```
or using curl
```
# stable version
curl -Lk https://raw.githubusercontent.com/wilas/vbkick/stable/install.sh | sudo bash
curl -Lk https://raw.githubusercontent.com/wilas/vbkick/stable/install.sh | sudo UNINSTALL=1 bash

# development version
curl -Lk https://raw.githubusercontent.com/wilas/vbkick/master/install.sh | sudo STABLE=0 bash
curl -Lk https://raw.githubusercontent.com/wilas/vbkick/master/install.sh | sudo UNINSTALL=1 bash

# custom location
# curl -Lk https://raw.githubusercontent.com/wilas/vbkick/master/install.sh | sudo PREFIX="$HOME/bin" bash
# curl -Lk https://raw.githubusercontent.com/wilas/vbkick/master/install.sh | sudo UNINSTALL=1 PREFIX="$HOME/bin" bash
```

## Create own box definition

 - look into [templates](https://github.com/wilas/vbkick-templates) and choose OS (learn also how to organize own definitions)
 - look into [examples](examples) and customize your box
 - read about [available options](docs/DEFINITION_CFG.md) in vbmachine.cfg
 - read about [VMs validation](docs/VALIDATE.md)
 - [help yourself](docs/HELP_YOURSELF.md)

## How to use

### create a new vagrant box
```
vbkick build newVM
vbkick postinstall newVM
vbkick validate newVM
vbkick export newVM

vagrant box add newVM newVM.box
vagrant box list
```

### update an existing vagrant box
```
vbkick update existingVM
vbkick validate existingVM
vbkick export existingVM

vagrant box remove existingVM virtualbox
vagrant box add existingVM existingVM.box
vagrant box list
```

### snap hack
```
vbkick build vm_name                    # creates the new VM - this is usually the slowest part
vbkick shutdown vm_name                 # to create clone VM must be powered off
vbkick clone vm_name                    # creates a clone (gold image) of the VM - for another hacking session
vbkick on vm_name                       # turn on VM
vbkick postinstall vm_name              # extra configuration of the new VM

vbkick snap vm_name fresh-install       # save a work
vbkick ssh vm_name                      # hack
vbkick snap vm_name my-first-hack       # save a work
vbkick ssh vm_name                      # hack
vbkick snap vm_name my-second-hack      # save a work

vbkick shutdown vm_name                 # to restore snapshot VM must be powered off
vbkick resnap vm_name fresh-install     # restore saved work
vbkick on vm_name                       # turn on VM

vbkick play vm_name                     # automate hack
vbkick snap vm_name my-auto-hack        # save a work

vbkick lssnap vm_name                   # list all snapshots
```

# Commands

## vbkick

Works in both bash 3 and bash 4 (use POSIX mode). If you have trouble using script, [let me know](CONTRIBUTE.md).

```
$ cd to_directory_with vbmachine.cfg

$ man vbkick or vbkick help

vbkick  <action>     <vm_name>
vbkick  build        VM_NAME        # build the new VM
vbkick  postinstall  VM_NAME        # run postinstall scripts via SSH
vbkick  play         VM_NAME        # run play scripts via SSH
vbkick  validate     VM_NAME        # run validate scripts via SSH
vbkick  update       VM_NAME        # run update scripts via SSH
vbkick  export       VM_NAME        # exports the VM and creates Vagrant base box - VM_NAME.box
vbkick  destroy      VM_NAME        # shut down and deletes the VM
vbkick  ssh          VM_NAME        # connect to the VM via SSH
vbkick  on           VM_NAME        # turn on the VM
vbkick  shutdown     VM_NAME        # shut down the VM
vbkick  clone        VM_NAME        # clone the VM
vbkick  lssnap       VM_NAME        # list all snapshots for a given VM
vbkick  snap         VM_NAME        # take the snapshot
vbkick  resnap       VM_NAME        # restore the snapshot
vbkick  delsnap      VM_NAME        # destroy the snapshot
vbkick  list                        # list all VirtualBox machines with the state
vbkick  version                     # print the version and exit
vbkick  help                        # print help
```

## vbtyper.pm

Helps enter key-strokes into a VirtualBox VMs programmatically from the host.
It is a [filter](http://en.wikipedia.org/wiki/Filter_%28Unix%29) - handle input from pipe or file.

Example:
```
$ printf "Hello VM" | vbtyper.pm VM_NAME
$ printf "<Hello*3> VM" | vbtyper.pm VM_NAME
```

Example keyboard scancodes:
```
$ printf "Hello VM" | vbtyper.pm
2a 23 a3 aa 12 92 26 a6 26 a6 18 98 39 b9 2a 2f af aa 2a 32 b2 aa

$ printf "<H*3>" | vbtyper.pm
2a 23 a3 aa 2a 23 a3 aa 2a 23 a3 aa

$ printf "<<Wait>*3>" | vbtyper.pm
wait wait wait
```

Special keys:

`<Wait>` -  helps control boot flow within vbkick

`<what*N>` - repeats "what" N times

# Bibliography
 - [veewee](https://github.com/jedi4ever/veewee)
 - [vagrant](https://github.com/mitchellh/vagrant)
 - [VirtualBox manual](http://www.virtualbox.org/manual/ch08.html)
 - [The UNIX Philosophy](http://en.wikipedia.org/wiki/Unix_philosophy#Mike_Gancarz:_The_UNIX_Philosophy)
 - [Filter (Unix)](http://en.wikipedia.org/wiki/Filter_%28Unix%29)
 - [BDD with shell scripts](http://chrismdp.com/2013/03/bdd-with-shell-script/)


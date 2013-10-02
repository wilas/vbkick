# Description

vbkick - simple bash tool for building Virtualbox Guests and Vagrant Base Boxes (replacement to [Veewee](https://github.com/jedi4ever/veewee) - [Why ?](docs/WHY.md))

vbkick works on Linux, FreeBSD, MacOSX with [basic requirements](docs/REQUIREMENTS.md)

# Getting Started

## Prelude
```
    # clone repo including submodules e.g. templates
    git clone --recursive git@github.com:wilas/vbkick.git

    # default (master) branch is for development, if you prefere use more stable version - choose stable branch
    git checkout stable
```

## Install/Uninstall

```
    sudo make install
    sudo make uninstall

    or advance:

    # sudo BASH_SHEBANG="/usr/bin/env bash" PY_SHEBANG="/usr/bin/env python" PREFIX="/tmp/testme/bin" make install
    sudo PREFIX="/tmp/testme/bin" make install
    sudo PREFIX="/tmp/testme/bin" make uninstall
```

## Create own box definition

 - look on [templates](templates) and choose OS (learn also how to organize own definitions)
 - look on [examples](examples) and customize your box
 - read about [available options](docs/DEFINITION_CFG.md) in definition.cfg
 - read about [VM Guest validation](docs/VALIDATE.md)
 - [help yourself](docs/HELP_YOURSELF.md)

## Child steps

### create new vagrant box
```
    vbkick build newVM
    vbkick postinstall newVM
    vbkick validate newVM
    vbkick export newVM

    vagrant box add newVM newVM.box
    vagrant box list
```

### update existing vagrant box
```
    vbkick update existingVM
    vbkick validate existingVM
    vbkick export existingVM
 
    vagrant box remove existingVM virtualbox
    vagrant box add existingVM existingVM.box
    vagrant box list
```

# Commands

## vbkick

Works in both bash 3 and bash 4 (use POSIX mode). If you have trouble using script, let me know.

```
    cd to_directory_with definition.cfg

    man vbkick

    vbkick  <action>     <vm_name>
    vbkick  build        VM_NAME        # build VM
    vbkick  postinstall  VM_NAME        # run postinstall scripts via ssh
    vbkick  validate     VM_NAME        # run validate/feature scripts via ssh
    vbkick  export       VM_NAME        # export VM and creates Vagrant VM_NAME.box
    vbkick  update       VM_NAME        # run update scripts via ssh
    vbkick  destroy      VM_NAME        # destroy VM
    vbkick  ssh          VM_NAME        # ssh to VM
    vbkick  on           VM_NAME        # turn on VM
    vbkick  shutdown     VM_NAME        # shutdown VM
    vbkick  help                        # display help and exit
```

## convert_2_scancode.py

Help enter key-strokes into a VirtualBox guest programmatically from the host.
It is a [filter](http://en.wikipedia.org/wiki/Filter_%28Unix%29) - handle input from pipe or file.

Works in both python 2.6+ and python 3.

Example:
```
    $ VBoxManage controlvm VM_NAME keyboardputscancode $(printf "Hello VM" | convert_2_scancode.py)
    $ VBoxManage controlvm VM_NAME keyboardputscancode $(printf "<Multiply(Hello, 3)> VM" | convert_2_scancode.py)
```

Example keyboard scancodes:
```
    $ printf "Hello VM" | convert_2_scancode.py
    2a 23 a3 aa 12 92 26 a6 26 a6 18 98 39 b9 2a 2f af aa 2a 32 b2 aa

    $ printf "<Multiply(H,3)>" | convert_2_scancode.py
    2a 23 a3 aa 2a 23 a3 aa 2a 23 a3 aa
    
    $ printf "<Multiply(<Wait>,3)>" | convert_2_scancode.py
    wait wait wait 
```

Special keys:

`<Wait>` -  help control boot flow within vbkick (FYI: can not be use directly with VBoxManage)

```
    $ VBoxManage controlvm VM_NAME keyboardputscancode $(printf "Hello <Wait> VM" | convert_2_scancode.py)
    VBoxManage: error: Error: 'wait' is not a hex byte!
```

`<Multiply(what, N)>` - repeat "what" N times


# Model and Philosophy (base on Unix)

Model:
 - lots of small tools that can be combined in lots of useful ways

Philosophy:
 - do one thing well,
 - small is beautiful, easy to write and easy to maintain,
 - gracefully handle errors and signals,
 - more: Mike Gancarz [The UNIX Philosophy](http://en.wikipedia.org/wiki/Unix_philosophy#Mike_Gancarz:_The_UNIX_Philosophy).


# Bibliography

 - !! veewee: https://github.com/jedi4ever/veewee
 - !! vagrant: https://github.com/mitchellh/vagrant
 - virtualbox manual: http://www.virtualbox.org/manual/ch08.html
 - controle vm with api: http://www.jedi.be/blog/2009/11/17/controlling-virtual-machines-with-an-API/
 - !! Unix Philosophy: http://en.wikipedia.org/wiki/Unix_philosophy
 - Filter (Unix): http://en.wikipedia.org/wiki/Filter_%28Unix%29
 - well-behave Python cmd line app: http://www.slideshare.net/gjcross/tutorial1-14045370
 - manpage creation: http://www.linuxhowtos.org/System/creatingman.htm (http://www.cyberciti.biz/faq/linux-unix-creating-a-manpage/)
 - BDD with shell scripts: http://chrismdp.com/2013/03/bdd-with-shell-script/
 - expect + passwd: http://www.linuxquestions.org/questions/linux-newbie-8/ssh-with-password-533684/

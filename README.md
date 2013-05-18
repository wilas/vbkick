# Description

vbkick - simple bash tool for building Virtualbox Guests and Vagrant Base Boxes (replacement to Veewee).

# Getting Started

## Get sources
```
    # clone repo including submodules e.g. templates
    git clone --recursive git@github.com:wilas/vbkick.git

    # default (master) branch is for development, if you prefere use more stable version - choose stable branch
    git checkout stable
```

## Easy install/uninstall

```
    sudo make install
    sudo make uninstall
```

## Manual install/uninstall

```
    sudo install -m 0755 -p vbkick convert_2_scancode.py /usr/local/bin/
    sudo cd /usr/local/bin/ && rm -f vbkick convert_2_scancode.py
```

## Create own box definition

 - look into [examples](examples) and choose method
 - look into [templates](templates) and choose OS (learn also how to organize own definitions)
 - read about [available options](docs/DEFINITION_CFG.md) in definition.cfg

# Commands

## vbkick

Tested currently only in bash 4.

If you have trouble using script in bash 3, let me know - create issue or send mail to help.vbkick[at]gmail.com.

```
    cd to_directory_with definition.cfg

    vbkick help

    vbkick  <action>     <vm_name>
    vbkick  build        VM_NAME        # build VM
    vbkick  postinstall  VM_NAME        # run postinstall scripts via ssh
    vbkick  validate     VM_NAME        # Not Implemented yet !!!
    vbkick  export       VM_NAME        # export VM and create Vagrant VM_NAME.box
    vbkick  destroy      VM_NAME        # destroy VM
```

## convert_2_scancode.py

Help enter key-strokes into a VirtualBox guest programmatically from the host.

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

`<Multiply(what, N)>` - repeat "what" N times

```
    $ VBoxManage controlvm VM_NAME keyboardputscancode $(printf "Hello <Wait> VM" | convert_2_scancode.py)
    VBoxManage: error: Error: 'wait' is not a hex byte!
```

# TODO:

```
vbkick:275:    # todo [MEDIUM]: wait until machine will be rebooted and ssh start working (before kickstart_timeout),
vbkick:377:        # todo [MEDIUM]: shutdown VM using ssh and halt/poweroff cmd (nicer for OS)
vbkick:437:    # todo [MEDIUM]: test should be smart enought to check what I really want to test
```

# Bibliography

 - !! veewee: https://github.com/jedi4ever/veewee
 - !! vagrant: https://github.com/mitchellh/vagrant
 - virtualbox manual: http://www.virtualbox.org/manual/ch08.html
 - controle vm with api: http://www.jedi.be/blog/2009/11/17/controlling-virtual-machines-with-an-API/

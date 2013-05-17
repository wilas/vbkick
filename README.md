# Description

vbkick - simple bash tool for building Vagrant Base Boxes and Virtualbox Guests (replacement to veewee).

About:
    
Ideas:
 - https://github.com/wilas/veewee-boxarium/tree/master/definitions/SL6_ks
 - https://github.com/wilas/veewee-boxarium/

Why:
 - vagrant 1.1+

# Getting started

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

 - look into [examples](https://github.com/wilas/vbkick/tree/master/examples) and choose method
 - look into [templates](https://github.com/wilas/vbkick/tree/master/templates) and choose OS
 - read about definition.cfg options


# Commands - child steps

## vbkick

```
    cd to_directory_with definition.cfg

    vbkick help

    vbkick build VM_NAME
    vbkick postinstall VM_NAME
    vbkick export VM_NAME
    vbkick destroy VM_NAME
```

## convert_2_scancode.py

Help enter key-strokes into a VirtualBox guest programmatically from the host.

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

Extra keys:

`<Wait>` -  help control boot flow within vbkick (FYI: can not be use directly with VBoxManage)

`<Multiply(what, N)>` - repeat "what" N times

```
    $ VBoxManage controlvm VM_NAME keyboardputscancode $(printf "Hello <Wait> VM" | convert_2_scancode.py)
    VBoxManage: error: Error: 'wait' is not a hex byte!
```

## Bibliography

 - !! veewee: https://github.com/jedi4ever/veewee
 - !! vagrant: https://github.com/mitchellh/vagrant
 - virtualbox manual: http://www.virtualbox.org/manual/ch08.html
 - controle vm with api: http://www.jedi.be/blog/2009/11/17/controlling-virtual-machines-with-an-API/


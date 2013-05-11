# Description

vbkick - bash tool for building Vagrant base boxes and guest Virtualbox machines (replacement to veewee).

About:
    
Ideas:
 - https://github.com/wilas/veewee-boxarium/tree/master/definitions/SL6_ks
 - https://github.com/wilas/veewee-boxarium/

Why:
 - vagrant 1.1+

## Getting started

### Easy installation

```
    coming soon
```

### Manual installation

```
    sudo cp convert_2_scancode.py /usr/local/bin/
    sudo chmod 755 /usr/local/bin/convert_2_scancode.py
    sudo cp vbkick.sh /usr/local/bin/vbkick
    sudo chmod 755 /usr/local/bin/vbkick
```

### Create own box definition

 - look into [examples](https://github.com/wilas/vbkick/tree/master/examples) and choose method
 - look into [templates](https://github.com/wilas/vbkick/tree/master/templates) and choose OS
 - read about definition.cfg options


## Usage

### vbkick

```
    cd to_directory_with definition.cfg

    vbkick help

    vbkick build VM_NAME
    vbkick postinstall VM_NAME
    vbkick export VM_NAME
    vbkick destroy VM_NAME
```

### convert_2_scancode.py

Enter key-strokes into a VirtualBox guest programmatically from the host:
```
    $ VBoxManage controlvm VM_NAME keyboardputscancode $(printf "Hello VM" | convert_2_scancode.py)
    $ VBoxManage controlvm VM_NAME keyboardputscancode $(printf "<Multiply(Hello, 3)> VM" | convert_2_scancode.py)
```

Example output keyboard scancodes:
```
    $ printf "Hello VM" | convert_2_scancode.py
    2a 23 a3 aa 12 92 26 a6 26 a6 18 98 39 b9 2a 2f af aa 2a 32 b2 aa

    $ printf "<Multiply(H,3)>" | convert_2_scancode.py
    2a 23 a3 aa 2a 23 a3 aa 2a 23 a3 aa
    
    $ printf "<Multiply(<Wait>,3)>" | convert_2_scancode.py
    wait wait wait 
```

Extra keys:

`<Wait>` - can not be use directly with VBoxManage, but help control boot flow within vbkick

`<Multiply(what, times)>` - help repeat "what" key

```
    $ VBoxManage controlvm VM_NAME keyboardputscancode $(printf "Hello <Wait> VM" | convert_2_scancode.py)
    VBoxManage: error: Error: 'wait' is not a hex byte!
```

## Bibliography

 - !! veewee: https://github.com/jedi4ever/veewee
 - !! vagrant: https://github.com/mitchellh/vagrant
 - virtualbox manual: http://www.virtualbox.org/manual/ch08.html
 - controle vm with api: http://www.jedi.be/blog/2009/11/17/controlling-virtual-machines-with-an-API/


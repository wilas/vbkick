# Description

https://github.com/wilas/veewee-boxarium/tree/master/definitions/SL6_ks
https://github.com/wilas/veewee-boxarium/

## TODO

 - wget/curl installer
 - docs and manuals
 - manifest

## convert_2_scancode.py

Enter key-strokes into a VirtualBox guest programmatically from the host:
```
$ VBoxManage controlvm VM_NAME keyboardputscancode $(echo -en 'Hello VM' | python convert_2_scancode.py)
```

Example output keyboard scancodes:
```
$ echo -en 'Hello VM' | python convert_2_scancode.py
2a 23 a3 aa 12 92 26 a6 26 a6 18 98 39 b9 2a 2f af aa 2a 32 b2 aa
```


# Description

Place for various random notes.

# Not supported platforms

Some bits needed to extend support for other platforms.

## Solaris

### sort command

GNU: `sort -gu`
Solaris: `sort -u`

Solution: `alias` or `${_sort}` base on OS

### whitespaces

POSIX allows use `[:space:]` character class, but (`grep` as an example):

Solaris:
```
echo "State:   running " | grep "State:[[:space:]]*running" | od -c
0000000

echo "State:   running " | grep "State:[ ]*running" | od -c
0000000   S   t   a   t   e   :               r   u   n   n   i   n   g
0000020    
0000021
```
FreeBSD, GNU/Linux:
```
echo "State: \t  running " | grep "State:[[:space:]][[:space:]]*running" | od -c
0000000    S   t   a   t   e   :      \t           r   u   n   n   i   n
0000020    g      \n                                                    
0000023
```

Solution: use `[ ]` if possible or cheat with `${TAB}` variable. At the moment everywhere `[ ]` are used.

## Windows

- **git-bash** (because machines are defined as a code) or Cygwin, MinGW, MobaXterm

Required steps (not tested yet):
 - install git-bash: http://git-scm.com/downloads
 - install virtualbox: https://www.virtualbox.org/wiki/Downloads
 - start git-bash
 - update $PATH inside **git-bash** with path to virtualbox.
```
    # this is simple example which requires improvements
    vim ~/.bashrc
    PATH=$PATH:/c/Program\ Files/Oracle/VirtualBox
    # source bashrc to update PATH or relaunch git-bash
    . ~/.bashrc
```
 - test command
```
    VBoxManage -v
```
 - install vbkick to `/bin` within **git-bash**
```
    git clone https://github.com/wilas/vbkick
    cd vbkick
    PREFIX=/bin make install
```

# Contribute - priorities:
 - LOW - (cosmetic problem, nothing important but nice to have) [COULD, WOULD]
 - MEDIUM - ({default} minor loss of func. easy workaround is present , not as time-critical, can be held back until a future delivery) [SHOULD]
 - HIGH - (major loss of function, critical/serious bugs affected the operation of the program) [MUST]
 - Info: http://en.wikipedia.org/wiki/MoSCoW_Method
 - Info: https://confluence.atlassian.com/display/JIRA/Defining+'Priority'+Field+Values

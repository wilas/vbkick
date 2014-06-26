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
printf "State: \t  running \n" | grep "State:[[:space:]][[:space:]]*running" | od -c
0000000    S   t   a   t   e   :      \t           r   u   n   n   i   n
0000020    g      \n                                                    
0000023
```

Solution: use `[ ]` if possible or cheat with `${TAB}` variable. At the moment everywhere `[ ]` are used.

### own sed inplace

`sed -i` doesn't exist on Solaris.

```
__in_place_edit myfile.txt "/^#/!s/\(VBOX_VERSION\)=\"\([0-9\.]\+\)\"/\1=\"${_vb_version}\"/g"
__in_place_edit(){
    local __file_name="${1}"
    local __sed_expr="${2}"
    # TODO: more checking - e.g. whether file exists
    _tmp_autoupdate_file=$(TMPDIR=. mktemp -t 'vbkick.XXXXXXXXXX')
    if [[ -z "${_tmp_autoupdate_file}" ]]; then
        __log_error "mktemp command failed."
        return 1
    fi
    # better in-place file editing
    sed "${__sed_expr}" "${__file_name}" > "${_tmp_autoupdate_file}"\
    && mv "${_tmp_autoupdate_file}" "${__file_name}"
}
```

## Windows

Required steps:
 - install mingw and msys: http://genome.sph.umich.edu/wiki/Installing_MinGW_%26_MSYS_on_Windows
 - install git-bash if you want use git: http://git-scm.com/downloads
 - install virtualbox: https://www.virtualbox.org/wiki/Downloads
 - start msys
 - install dependencies using `mingw-get`
 - install curl (recommended with enabled SSL): http://curl.haxx.se/docs/install.html
 - update $PATH inside **msys** with path to virtualbox.
```
    # this is simple example which requires improvements
    vim ~/.bashrc
    PATH=$PATH:/c/Program\ Files/Oracle/VirtualBox
    # source bashrc to update PATH
    . ~/.bashrc
```
 - test command
```
    VBoxManage -v
```
 - install vbkick to `/bin` within **msys**
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

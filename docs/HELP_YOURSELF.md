# Shell autocompletion

add to ~/.bashrc
```
if command -v vbkick >/dev/null 2>&1; then
    complete -W "$(vbkick --help | awk '/^\t/{print $1}')" vbkick
fi
```

# git todo

add to ~/.gitconfig
```
[alias]
    todo  = grep -n --ignore-case -e 'TODO *'
    fixme = grep -n --ignore-case -e 'FIX: *' -e 'FIXME: *'
```

# general todo

add to ~/.bashrc
```
function todo() { grep -i -n --color -e "todo" * ; }
function todo_r() { grep -i -n -r --color -e "todo" * ; }
```

# colourful manual

add to ~/.bashrc
```
# https://wiki.archlinux.org/index.php/Man_Page
man() {
    env LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}
```

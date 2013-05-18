Dirty notes:
 - ! kickstart_port is setup in 2 places for injection postinstall: kickstart_file, definition.cfg
 - shell completion: https://github.com/mitchellh/vagrant/blob/master/contrib/bash/completion.sh
 - idea: I as vbkick want just kick Virtualbox and bring you OS to play (keep it simple - not too much features/options, do well one thing)
 - Create bootable usb stick from definition.cfg (os_type is a key)

Howto:
 - getopt: http://mywiki.wooledge.org/BashFAQ/035
 - expect + passwd: http://stackoverflow.com/questions/12202587/ssh-script-that-automatically-enters-password
 - expect + passwd: http://www.linuxquestions.org/questions/linux-newbie-8/ssh-with-password-533684/
 - sshpass: http://www.debianadmin.com/sshpass-non-interactive-ssh-password-authentication.html
 - some bash options (set -e; set -o pipefail): http://stackoverflow.com/questions/11231937/bash-ignoring-error-for-a-particular-command
 - bash script prelude: http://gfxmonk.net/2012/06/17/my-new-bash-script-prelude.html

Links: 
 - smartos: https://gist.github.com/benr/5505198
 - good to know about set -e: http://stackoverflow.com/questions/6930295/set-e-and-short-tests
 - Debian + kde + usb stick: http://www.debian.org/releases/stable/i386/apbs02.html.en
 - Centos + gnome + usb stick: http://wiki.centos.org/HowTos/InstallFromUSBkey

General TODO
 - wget/curl installer
 - docs and manuals
 - getting started, philosophy/approach, supported VM providers, about
 - contribute
    - Help yourself: to_do, to_do_r, autocompletion
    - to_do priority:
        - LOW - (cosmetic problem, nothing important but nice to have) [COULD, WOULD]
        - MEDIUM - ({default} minor loss of func. easy workaround is present , not as time-critical, can be held back until a future delivery) [SHOULD]
        - HIGH - (major loss of function, critical/serious bugs affected the operation of the program) [MUST]
        - Info: http://en.wikipedia.org/wiki/MoSCoW_Method
        - Info: https://confluence.atlassian.com/display/JIRA/Defining+'Priority'+Field+Values
    - howto contribute: (create issue) and/or (create branch, request pull) or (write email)
    - .gitconfig
 - templates as submodules
    - organization (dir: postinstall, kickstart, definition.cfg as symlink)
    - dir: keys, iso are not included
    - each template take care about “big” OS release, eg. Debian7, Redhat6, Redhat5
    - each template is independent submodule with person taking care about it (README.md [info about choosen postinstall method], LICENSE is required)
 - Ideas.md (arena + garden + levels/priority) and/or (create issu)
 - describe options in definition.cfg (possibility and consequences)(OS influence)

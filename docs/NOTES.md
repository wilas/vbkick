Dirty notes:
 - ! kickstart_port is setup in 2 places for injection postinstall: kickstart_file, definition.cfg
 - Create bootable usb stick from definition.cfg (os_type is a key)
 - natdnshostresolver1:on (when host is ubuntu12.10)

Links: 
 - good to know about set -e: http://stackoverflow.com/questions/6930295/set-e-and-short-tests
 - bash script prelude: http://gfxmonk.net/2012/06/17/my-new-bash-script-prelude.html
 - some bash options (set -e; set -o pipefail): http://stackoverflow.com/questions/11231937/bash-ignoring-error-for-a-particular-command
 - Debian + kde + usb stick: http://www.debian.org/releases/stable/i386/apbs02.html.en
 - Centos + gnome + usb stick: http://wiki.centos.org/HowTos/InstallFromUSBkey
 - kickstart/preseed - usb stick:  http://www.cyberciti.biz/faq/linux-create-a-bootable-usb-pen/

General TODO
 - creates curl installer: curl -ks "url" | sudo bash #(http://calibre-ebook.com/download_linux)
 - contribute
    - to_do priority:
        - LOW - (cosmetic problem, nothing important but nice to have) [COULD, WOULD]
        - MEDIUM - ({default} minor loss of func. easy workaround is present , not as time-critical, can be held back until a future delivery) [SHOULD]
        - HIGH - (major loss of function, critical/serious bugs affected the operation of the program) [MUST]
        - Info: http://en.wikipedia.org/wiki/MoSCoW_Method
        - Info: https://confluence.atlassian.com/display/JIRA/Defining+'Priority'+Field+Values
 - describe options in definition.cfg (possibility and consequences)(OS influence)(what each option mean, what I can do, what format is accepted + describe special variables in doc/definition.md)
 - benefits of having definition.cfg in bash format (simple func inside, read context from the central repo, include other definitions, e.g common)
 - more screens
 - usecase/workflow: (test kickstart files, test postinstall scripts, discover new things on vanilla boxes)(build vanilla, clone, play with clone, automate steps done on clone)(this is my cheap personal lab/garage)(sandbox env.)

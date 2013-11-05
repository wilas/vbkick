Dirty notes:
 - Create bootable usb stick from definition.cfg (os_type is a key)
 - natdnshostresolver1:on (when host is ubuntu12.10)

Links: 
 - good to know about set -e: http://stackoverflow.com/questions/6930295/set-e-and-short-tests
 - bash script prelude: http://gfxmonk.net/2012/06/17/my-new-bash-script-prelude.html
 - some bash options (set -e; set -o pipefail): http://stackoverflow.com/questions/11231937/bash-ignoring-error-for-a-particular-command
 - Debian + kde + usb stick: http://www.debian.org/releases/stable/i386/apbs02.html.en
 - Centos + gnome + usb stick: http://wiki.centos.org/HowTos/InstallFromUSBkey
 - kickstart/preseed - usb stick:  http://www.cyberciti.biz/faq/linux-create-a-bootable-usb-pen/
 - 1 is true and 0 is false in the usual boolean sense because of the arithmetic evaluation context: http://stackoverflow.com/questions/8579399/why-is-true-false-in-bash

General TODO
 - creates curl installer: curl -ks "url" | sudo bash #(http://calibre-ebook.com/download_linux)
 - contribute
    - to_do priority:
        - LOW - (cosmetic problem, nothing important but nice to have) [COULD, WOULD]
        - MEDIUM - ({default} minor loss of func. easy workaround is present , not as time-critical, can be held back until a future delivery) [SHOULD]
        - HIGH - (major loss of function, critical/serious bugs affected the operation of the program) [MUST]
        - Info: http://en.wikipedia.org/wiki/MoSCoW_Method
        - Info: https://confluence.atlassian.com/display/JIRA/Defining+'Priority'+Field+Values
 - benefits of having definition.cfg in bash format (simple func inside, read context from the central repo, include other definitions, e.g common)
 - usecase/workflow: (test kickstart files, test postinstall scripts, test provisioners, discover new things on vanilla boxes)(build vanilla, clone, play with clone, automate steps done on clone)(this is my cheap personal lab/garage)(sandbox env.); build and posinstall are separate - kickstarting may take time, so is good to make snapshot/clone just after kickstart but before posinstall; base for my_scripts/ansible_playbooks/puppet_modules; quick way to refresh vagrant boxes
 - templates
    - OmniOS stable – simple (latter install puppet, chef, ansible):  http://omnios.omniti.com/wiki.php/WikiStart
    - OpenIndiana – simple (latter install puppet, chef, ansible): http://wiki.openindiana.org/oi/Installing+OpenIndiana

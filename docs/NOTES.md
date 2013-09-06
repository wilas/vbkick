Dirty notes:
 - ! kickstart_port is setup in 2 places for injection postinstall: kickstart_file, definition.cfg
 - Create bootable usb stick from definition.cfg (os_type is a key)

Howto:
 - getopt: http://mywiki.wooledge.org/BashFAQ/035
 - expect + passwd: http://stackoverflow.com/questions/12202587/ssh-script-that-automatically-enters-password
 - expect + passwd: http://www.linuxquestions.org/questions/linux-newbie-8/ssh-with-password-533684/
 - sshpass: http://www.debianadmin.com/sshpass-non-interactive-ssh-password-authentication.html

Links: 
 - good to know about set -e: http://stackoverflow.com/questions/6930295/set-e-and-short-tests
 - bash script prelude: http://gfxmonk.net/2012/06/17/my-new-bash-script-prelude.html
 - some bash options (set -e; set -o pipefail): http://stackoverflow.com/questions/11231937/bash-ignoring-error-for-a-particular-command
 - Debian + kde + usb stick: http://www.debian.org/releases/stable/i386/apbs02.html.en
 - Centos + gnome + usb stick: http://wiki.centos.org/HowTos/InstallFromUSBkey

General TODO
 - wget/curl installer
 - contribute
    - to_do priority:
        - LOW - (cosmetic problem, nothing important but nice to have) [COULD, WOULD]
        - MEDIUM - ({default} minor loss of func. easy workaround is present , not as time-critical, can be held back until a future delivery) [SHOULD]
        - HIGH - (major loss of function, critical/serious bugs affected the operation of the program) [MUST]
        - Info: http://en.wikipedia.org/wiki/MoSCoW_Method
        - Info: https://confluence.atlassian.com/display/JIRA/Defining+'Priority'+Field+Values
 - Ideas.md (arena + garden + levels/priority) and/or (create issue)
 - describe options in definition.cfg (possibility and consequences)(OS influence)
 - prepare and boot VM from media disk attached to SATA Controller, port 0 (iso is not needed, useful for SmartOS)

Idea:
 - concurrent VM build (arg: list of VM) - CPU waste - better create one and use clone

Troubleshooting:
```
  $ vbkick build example
  7130 port is already in use
  $ ps -ef | grep python
  $ kill PID 
```

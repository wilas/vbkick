Dirty notes:
 - ! kickstart_port is setup in 2 places for internal postinstall: kickstart_file, definition.cfg
 - posinstall injection to /var/tmp (rest of job do adm_postinstall.sh)
 - transport approach -> only wget postinstall folder, rest may be done via ssh postinstall scripts
 - shell completion: https://github.com/mitchellh/vagrant/blob/master/contrib/bash/completion.sh

Howto:
 - getopt - http://mywiki.wooledge.org/BashFAQ/035


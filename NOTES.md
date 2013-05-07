Dirty notes:
 - ! kickstart_port is setup in 2 places for internal postinstall: kickstart_file, definition.cfg
 - posinstall injection to /var/tmp (rest of job do adm_postinstall.sh)
 - transport approach -> only wget postinstall folder, rest may be done via ssh postinstall scripts
 - shell completion: https://github.com/mitchellh/vagrant/blob/master/contrib/bash/completion.sh
 - convert_2_scancode.py -> write to sdterr if exception, returncode 1 (keep UNIX-like)

Howto:
 - getopt - http://mywiki.wooledge.org/BashFAQ/035

Links: 
 - smartos: https://gist.github.com/benr/5505198

getopt - http://mywiki.wooledge.org/BashFAQ/035

- ! PORT must be setup in 2/3 places for internal postinstall: kickstart_file, definition.cfg, virtualbox.sh
- posinstall injection to /var/tmp (adm_postinstall.sh do a job)
- transport approach -> only wget postinstall folder, rest may be done via ssh postinstall scripts


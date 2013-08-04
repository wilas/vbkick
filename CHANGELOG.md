## Not released

FEATURES
 - auto update VBOX_VERSION="version" in given files list with current vbox version

## 0.3.1 (22-06-2013)

FEATURES:
 - guest_additions_download option to enable/disable VBoxGuestAdditions download on host
 - CentOS6, Debian6, Debian7, Fedora18, Ubuntu12.04 templates were added

IMPROVEMENTS
 - use /dev/sr1 to install VBoxGuestAdditions instead of "wget method" (virtualbox.sh postinstall script as an example)
 - Q&A to confirm action during destroying VM is now before shutdown
 - use SSH keys is enabled by default

## 0.3 (27-05-2013)

FEATURES:
 - vbkick was teach how to validate VM
 - vbkick check whether VM was kickstarted before kickstart_timeout
 - clean VM shutdown via SSH and shutdown_cmd (nicer for OS)
 - Manual was added
 - enable/disable the automatic removal transported via SCP scripts (after postinstall or validate process)

IMPROVEMENTS:
 - POSIX mode enabled
 - colourful output - red when error, yellow when warning

## 0.2 (19-05-2013)

FEATURES:
 - vbkick was teach how to build VM from given definition.cfg
 - vbkick was teach how to "lazy" run postinstall scripts
 - vbkick was teach how to export VM to Vagrant base box
 - vbkick was teach how to destroy given VM
 - vbkick templates structure was designed
 - examples and descriptions for both postinstall methods were added
 - Makefile installer was added

## 0.1 
 - Initial release

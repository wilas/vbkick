## Not released

FEATURES
 - list of disks (given as list of disks sizes) instead of one disk
 - ssh ACTION was added - ssh to VM with same as postinstall/validate/update options
 - on ACTION was added - turn on given VM
 - shutdown ACTION was added - turn off given VM
 - ssh_password authentication was added, "expect" installed on host machine is needed to use this feature, otherwise it prompt you for a password
 - disbale/enable autoupdate VBoxGuestAdditions iso attached to guest machine (guest_additions_attach)
 - boot from other than dvddrive file (e.g. hdd) (usefull for SmartOS)
 - added options: boot_file, boot_file_type, boot_file_src, boot_file_src_sha256, boot_file_src_path, boot_file_unpack_name, boot_file_unpack_cmd, boot_file_convert_from_raw, guest_additions_path
 - removed options: iso_file, iso_path, iso_src, iso_sha256, guest_additions_download
 - extra variables %VBOXFOLDER%, %NAME%, %HOME%, %PWD% and %SRCPATH% in boot_file, boot_file_unpack_name, boot_file_unpack_cmd
 - extra variables %VBOXFOLDER%, %NAME%, %HOME% and %PWD% in boot_file_src_path
 - unpack boot_file_src media if necessary
 - convert from raw boot_file_src media if necessary
 - SmartOS template was added

IMPROVEMENTS
 - added delay between ssh commands; command not fail if previous contain `reboot`. Wait until host boot or ssh ConnectTimeout will be reached (useful for lxc-docker installation)
 - hdd disks are added to SATA Controller, ports 2-30 instead of ports 0-30; port 0 is reserve for boot disk, port 1 is reserve for guest additions
 - SATA for boot iso and guest additions instead of IDE
 - manuall_guest_install option was removed; update VBoxGuestAdditions should be a part of update_lauch (if required); it is easier to find a proper block device with additions on the guest machine: /dev/sr0 or /dev/sr1
 - "acpipowerbutton + 60 seconds" to shutdown VM before poweroff will be used
 - allow use disk_size=("") to not add hdd disks to VM

BUG FIXES
 - process lauch and transport arrays in ssh_exec

## 0.4 (28-08-2013)

FEATURES
 - vbkick was taught how to auto update VBoxGuestAdditions on Guest machine and "lazy" run other update scripts (manuall_update_guest_additions option)
 - auto update value of VBOX_VERSION="version" in the given files list with current vbox version
 - rm other (older) VBoxGuestAdditions isos from media directory (before remove ask about confirmation)
 - Fedora19 template was added

IMPROVEMENTS
 - guest_additions_download option is disbaled by default
 - instead downloading custom VBoxGuestAdditions image use default already existing on Host machine: "VBoxManage storageattach --medium additions" (it save space on disk and time)

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
 - vbkick was taught how to validate VM
 - vbkick check whether VM was kickstarted before kickstart_timeout
 - clean VM shutdown via SSH and shutdown_cmd (nicer for OS)
 - Manual was added
 - enable/disable the automatic removal transported via SCP scripts (after postinstall or validate process)

IMPROVEMENTS:
 - POSIX mode enabled
 - colourful output - red when error, yellow when warning

## 0.2 (19-05-2013)

FEATURES:
 - vbkick was taught how to build VM from given definition.cfg
 - vbkick was taught how to "lazy" run postinstall scripts
 - vbkick was taught how to export VM to Vagrant base box
 - vbkick was taught how to destroy given VM
 - vbkick templates structure was designed
 - examples and descriptions for both postinstall methods were added
 - Makefile installer was added

## 0.1 
 - Initial release

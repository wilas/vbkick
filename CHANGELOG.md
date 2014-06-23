## Not released

FEATURES
 - replace python by perl (perl is available out of the box in git-bash on Windows)
 - added `export_file` option to allow export vagrant base boxes to custom location

IMPROVEMENTS
 - simplify multiply expression in vbtyper.pl to `<what*N>`, the old method is deprecated

## 0.7 (04-06-2014)

FEATURES
 - added ansible, puppet, docker provisioner examples
 - added `nic_type` option to allow change type of networking hardware
 - added `boot_order` option to allow choose boot devices
 - added `version` ACTION to display vbkick version
 - added `lssnap` ACTION to list all snapshots
 - added `snap` ACTION to take a new snapshot
 - added `resnap` ACTION to restore a snapshot
 - added `delsnap` ACTION to delete a snapshot
 - added `clone` ACTION to clone VM
 - added `play` ACTION to separate postinstall process from the tinkering
 - added curl installer
 - path to the VBoxManage can be changed now by VBOX_MANAGE_PATH env. variable
 - vbkick tries update SSH host port in the NAT configuration if is used a different than already setup

IMPROVEMENTS
 - works with Virtualbox 4.3 - [#32](../../issues/32)
 - works when IPV6 is enabled and `::1     localhost` appear in `/etc/hosts` - [#33](../../issues/33)
 - checks curl status code
 - empty `boot_file_src_checksum` variable mean don't compare checksums
 - auto destroy VM during building if all VM settings weren't correctly setup - be a bit more atomic
 - checks whether vm exist for the `shutdown` action
 - checks whether `shutdown_cmd` option is empty, if so use acpipowerbutton
 - checks more VM states like 'paused' instead of only 'running' and 'powered off'
 - separate repos for templates were created
 - `md5` as a default checksum type - not everywhere openssl has `sha256` digest command
 - added shutdown time monitoring for the acpipowerbutton

BUG FIXES
 - expand a special variables in paths e.g. `~` (tilde) is now not treated as a literal string "~" but expand to user home dir.
 - portable `sed`

## 0.6 (22-10-2013)

FEATURES
 - added option `webserver_disabled` to not start local webserver when remote host is prefered to serve files (or files from webserver are not need)
 - `definition_file_name` as 3rd (optional) argument - [#26](../../issues/26)
 - added `ssh_port_name` to allow change ssh port forwarding name (was hardcoded "vbkickSSH")
 - `shared_folders` as an array, to allow share more than one folder
 - added `extra_ports` mapping, to allow map other than ssh port
 - added `vm_extradata` option, to allow set extra data ("VBoxManage setextradata")
 - Mer, NemoMobile, PlasmaActive templates were added

IMPROVEMENTS
 - all files which should be transported to VM guest are checked before transport start processing any of them
 - extra variables `%VBOXFOLDER%`, `%NAME%`, `%HOME%` and `%PWD%` in `{postinstall/update/validate}_launch` are acceptable after %HOST% (to run commands on local host not guest)
 - removed `netcat` dependency
 - check whether process exist and accept signals before sending SIGTERM

BUG FIXES
 - better cleaning already scp files
 - vbkick exit and report error when ssh command fail in `posinstall/update/validate` actions - [#28](../../issues/28)
 - proper processes VT keys (`LeftAlt + RightCtrl + F1-12`)

## 0.5.1 (30-09-2013)

FEATURES
 - added option: `keep_boot_src_file` - keep or not source of `boot_file` when boot file is created (use mv or cp); by default 0 - mean do not keep.
 - replace `boot_file_src_sha256` option by `boot_file_src_checksum` + `boot_file_checksum_type`, it allow use different hashing algorithms

IMPROVEMENTS
 - the Installer allow specify the install location and the shebang - more [#1](../../issues/1), [#2](../../issues/2) and [#14](../../issues/14)
 - automatically disable GUI if `VirtualBox` command doesn't exist, you can still force enable GUI in `definition.cfg`
 - checks SSH port usage before creating VM
 - checks required options in `definition.cfg`
 - checks required dependencies at the start of the script
 - `curl` instead of `wget` as downloader
 - `command -v` instead of `which`
 - removed `getent` dependency
 - "if statement" compatibility

BUG FIXES
 - vbkick works on systems where python 3 is the default one - [#5](../../issues/5)

## 0.5 (15-09-2013)

FEATURES
 - list of disks (given as list of disks sizes) instead of one disk
 - `ssh` ACTION was added - ssh to VM with same as postinstall/validate/update options
 - `on` ACTION was added - turn on given VM
 - `shutdown` ACTION was added - turn off given VM
 - ssh_password authentication was added, "expect" installed on host machine is needed to use this feature, otherwise it prompt you for a password
 - attach or not a VBoxGuestAdditions ISO to guest machine (`guest_additions_attach`)
 - boot from other than dvddrive file (e.g. hdd) (usefull for SmartOS)
 - added options: `boot_file`, `boot_file_type`, `boot_file_src`, `boot_file_src_sha256`, `boot_file_src_path`, `boot_file_unpack_name`, `boot_file_unpack_cmd`, `boot_file_convert_from_raw`, `guest_additions_path`
 - removed options: `iso_file`, `iso_path`, `iso_src`, `iso_sha256`, `guest_additions_download`
 - extra variables `%VBOXFOLDER%`, `%NAME%`, `%HOME%`, `%PWD%` and `%SRCPATH%` in `boot_file`, `boot_file_unpack_name`, `boot_file_unpack_cmd`
 - extra variables `%VBOXFOLDER%`, `%NAME%`, `%HOME%` and `%PWD%` in `boot_file_src_path`
 - `%HOST%` in postinstall/validate/update lauch definition to execute given cmd on host not guest machine (e.g.: %HOST% sleep 20)
 - unpack boot_file_src media if necessary
 - convert from raw boot_file_src media if necessary
 - SmartOS template was added

IMPROVEMENTS
 - SATA for boot iso and guest additions instead of IDE
 - hdd disks are added to SATA Controller, ports 2-30 instead of ports 0-30; port 0 is reserve for boot disk, port 1 is reserve for guest additions
 - `manuall_guest_install` option was removed; update VBoxGuestAdditions should be a part of update_lauch (if required); it is easier to find a proper block device with additions on the guest machine: /dev/sr0 or /dev/sr1
 - "acpipowerbutton + shutdown_timeout seconds" to shutdown VM before poweroff will be used (both are used if normal shutdwon fail)
 - allow use `disk_size=("")` to not add hdd disks to VM

BUG FIXES
 - process lauch and transport arrays in ssh_exec

## 0.4 (28-08-2013)

FEATURES
 - vbkick was taught how to auto update VBoxGuestAdditions on Guest machine and "lazy" run other update scripts (`manuall_update_guest_additions` option)
 - auto update value of VBOX_VERSION="version" in the given files list with current vbox version
 - rm other (older) VBoxGuestAdditions isos from media directory (before remove ask about confirmation)
 - Fedora19 template was added

IMPROVEMENTS
 - `guest_additions_download` option is disbaled by default
 - instead downloading custom VBoxGuestAdditions image from internet use default already existing on Host machine: "VBoxManage storageattach --medium additions" (it save space on disk and time)

## 0.3.1 (22-06-2013)

FEATURES:
 - guest_additions_download option to enable/disable VBoxGuestAdditions download from internet and use local GuestAdditions ISO instead
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
 - signals processing was added - e.g. SIGINT (Ctrl-C) during waiting for boot

## 0.1
 - Initial release

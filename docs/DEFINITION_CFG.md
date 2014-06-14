# Available options in vbmachine.cfg

More details soon.

### Table of Contents
 - [VM](#vm)
 - [GUEST ADDITIONS](#guest-additions)
 - [BOOT](#boot)
 - [SSH](#ssh)
 - [POSTINSTALL](#postinstall)
 - [VALIDATE](#validate)
 - [UPDATE](#update)
 - [CLEAN](#clean)


## VM

 - cpu_count

 default: 1

 - memory_size

 default: 512

 - disk_size

 default: (10140)

 - disk_format

 default: "vdi"

 - video_memory_size

 default: 10

 - hostiocache

 default: "on"

 - boot_order

 default: ("disk" "dvd")

 - nic_type

 default: "82540EM"

 - vm_options

 default: ("ioapic:on")

 - vm_extradata

 default: ("")

 - gui_enabled

 default: 1 - mean gui enabled

 - shared_folders

 default: ("vbkick:%PWD%:automount")

 - extra_ports

 default: ("")

 - os_type_id

 no default - REQUIRED!


## GUEST ADDITIONS

 - guest_additions_path

 default: ""

 - guest_additions_attach

 default: 1


## BOOT

 - boot_file

 no default - REQUIRED!

 - boot_file_type

 default: "dvddrive"

 - boot_file_src

 no default - REQUIRED!

 - boot_file_src_path

 default: "iso"

 - boot_file_src_checksum

 default: ""

 - boot_file_checksum_type

 default: "md5"

 - boot_file_unpack_cmd

 default: ""

 - boot_file_unpack_name

 default: ""

 - boot_file_convert_from_raw

 default: 0

 - keep_boot_src_file

 default: 0

 - boot_wait

 default: 10

 - boot_cmd_sequence

 default: ("")

 - boot_seq_wait

 default: 1

 - kickstart_port

 default: 7122

 - kickstart_timeout

 default: 7200

 - webserver_disabled

 default: 0

## SSH

 - ssh_keys_enabled

 default: 1

 - ssh_user

 default: "vbkick"

 - ssh_password

 default: "vbkick"

 - ssh_keys_path

 default: "keys"

 - ssh_priv_key

 default: "vbkick_key"

 - ssh_priv_key_src

 default: "https://raw.github.com/wilas/vbkick/master/keys/vbkick_key"

 - ssh_host_port

 default: 2222

 - ssh_guest_port

 default: 22

 - ssh_port_name

 default: "vbkickSSH"

 - ssh_options

 default: "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1"


## POSTINSTALL

 - postinstall_launch

 default: ("")

 - postinstall_transport

 default: ("")


## PLAY

 - play_launch

 default: ("")

 - play_transport

 default: ("")


## VALIDATE

 - validate_launch

 default: ("")

 - validate_transport

 default: ("")


## UPDATE

 - update_transport

 default: ("")

 - update_launch

 default: ("")

## EXPORT

 - export_file

 default: "./%NAME%.box"


## CLEAN

 - clean_transported

 default: 0

 - shutdown_cmd

 default: ""

 - shutdown_timeout

 default: 20

 - files_to_autoupdate_vbox_version

 default: ("")

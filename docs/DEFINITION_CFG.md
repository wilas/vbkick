# Available options in definition.cfg 

More details soon.

## VM

 - cpu_count

 default: 1

 - memory_size

 default: 512

 - disk_size

 default: 10140

 - disk_format

 default: "vdi"

 - video_memory_size

 default: 10

 - hostiocache

 default: "on"

 - vm_options

 default: ("ioapic:on")

 - gui_enabled

 default: 1 - mean gui enabled

 - shared_folder

 default: "vbkick"

 - os_type_id

 no default - REQUIRED!


## ISO

 - iso_path

 default: "iso"

 - iso_file

 no default - REQUIRED!

 - iso_src

 no default - REQUIRED! 

 Note: may be equal "" if iso_file exist in iso_path - downloaded manually

 - iso_sha256

 default: ""


## BOOT

 - boot_wait

 default: 10

 - boot_cmd_sequence

 default: ("")

 - kickstart_port

 default: 7122

 - kickstart_timeout

 default: 7200


## SSH

 - ssh_keys_enabled

 default: 1

 - ssh_user

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

 - ssh_options

 default: "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"


## POSTINSTALL

 - postinstall_launch

 default: ("")

 - postinstall_transport

 default: ("")


## VALIDATE

 - validate_launch

 default: ("")

 - validate_transport

 default: ("")


## CLEAN

 - clean_transported

 default: 0

 - shutdown_cmd

 default: "sudo /sbin/halt -h -p"

 - shutdown_timeout

 default: 20


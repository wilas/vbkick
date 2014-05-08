# Examples - how to customize box definition.

## Example definition.cfg - the core file of each box.

```
    cpu_count=1
    memory_size=512
    disk_size=(10140)
    disk_format="vdi"
    video_memory_size=10
    hostiocache="on"
    vm_options=("ioapic:on")
    os_type_id="RedHat_64"
    boot_file="%SRCPATH%/SL-64-x86_64-2013-03-18-boot.iso"
    boot_file_src="http://ftp1.scientificlinux.org/linux/scientific/6.4/x86_64/iso/SL-64-x86_64-2013-03-18-boot.iso"
    boot_file_src_path="iso"
    boot_file_checksum_type="sha256"
    boot_file_src_checksum="f0ccbd8cb802b489ab6a606c90f05f5d249db1cb1e0e931dbb703240b4d97d8c"
    guest_additions_attach=1
    boot_wait=10
    boot_cmd_sequence=(
        "<Tab> text ks=http://%IP%:%PORT%/kickstart/scientificlinux-6.4-x86_64-lazy_noX.cfg<Enter>"
    )
    kickstart_port=7122
    kickstart_timeout=7200
    ssh_host_port=2222
    ssh_user="vagrant"
    ssh_priv_key="vagrant_key"
    ssh_priv_key_src="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant"
    postinstall_launch=("cd postinstall && sudo bash adm_postinstall.sh")
    postinstall_transport=("postinstall")
    validate_launch=("cd validate && bash adm_features.sh")
    validate_transport=("validate")
    update_launch=(
        "sudo bash postinstall/virtualbox.sh"
        "sudo bash -c 'yum -y update && yum -y clean all'"
    )
    update_transport=("postinstall")
    clean_transported=1
    shutdown_cmd="sudo /sbin/halt -h -p"
    shutdown_timeout=20
```

## Typical build flow.

Starting
 - creates own definition based on selected template
 - cmd: `vim definition-6.4-x86_64-my_custom.cfg`
 - cmd: `ln -fs definition-6.4-x86_64-my_custom.cfg definition.cfg`

Building - `vbkick build VM_NAME`
 - creates a new VM
 - download install media
 - boot (kickstart) machine and talk to installer using boot_cmd_sequence
 - wait until machine is ready or a timeout is reached

Tuning - `vbkick postinstall VM_NAME`
 - [postinstall VM configuration](../docs/POSTINSTALL.md) - transport posinstall scripts via SCP and exec launch commands via SSH
 - consider use configuration management [provisioners](../docs/PROVISIONERS.md)

Testing - `vbkick validate VM_NAME`
 - validate the new VM

Releasing - `vbkick export VM_NAME`
 - export machine as a vagrant box

Updating - `vbkick update VM_NAME`
 - update already existing VM

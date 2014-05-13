# Examples

## Examples description

- SL6_injection_method - shows how to configure VM in chroot environment during installation/kickstarting process
- SL6_lazy_method - shows how to configure VM "later" after OS installation **(the most typical use case)**
- SL6_provisioner - shows how to use puppet, ansible and docker with vbkick to tunning VM **(the most advanced examples)**

All examples use Scientific Linux as an OS.

## Typical build flow.

Starting
 - creates own definition based on selected template
 - cmd: `vim definition-6.5-x86_64-my_custom.cfg`
 - cmd: `ln -fs definition-6.5-x86_64-my_custom.cfg definition.cfg`

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
 - export machine as a vagrant base box

Updating - `vbkick update VM_NAME`
 - update already existing VM


## Hints

definition.cfg file is a pure bash, so we can benefit from this.

### create a simple functions

useful to e.g. automatically download checksum
```
# in definition.cfg
get_smartos_md5() {
    local img_type="${1}"
    local latest_nr=$(get_smartos_latest_nr)
    local base_url="https://us-east.manta.joyent.com//Joyent_Dev/public/SmartOS"
    local smartos_md5_sum=$(curl -ks "${base_url}/${latest_nr}/md5sums.txt" | grep "${img_type}" | cut -d" " -f 1)
    printf "${smartos_md5_sum}"
}
get_smartos_latest_nr() {
    local base_url="https://us-east.manta.joyent.com//Joyent_Dev/public/SmartOS"
    local url=$(curl -ks "${base_url}/latest.html" | sed 's~.*url=\(.*\)index.html.*~\1~')
    local latest_nr=$(basename $url)
    printf "${latest_nr}"
}
boot_file_src_checksum=$(get_smartos_md5 USB.img.bz2)
```

Note1: be carefull with creating too much and too big functions in a definition files - be simple

Note2: If you have a bug in your definition file (e.g. syntax),
then vbkick fails (cleanly terminates) during definition loading.

### create ENV variables

useful to run some random commands on VM without runing login shell
```
# in definition.cfg
play_launch=(
# this is a comment and won't be processed
  "sudo docker ps -a"
  "${SSH_CMD:-}"
)
play_transport=("play_docker")

# cmd line
$ SSH_CMD='ls -la' vbkick play vm_name
$ SSH_CMD='sudo docker pull busybox' vbkick play vm_name
$ SSH_CMD='sudo docker run busybox /bin/echo hello world' vbkick play vm_name
$ vbkick play vm_name
```

useful to test multiple machines in the same time which were built from the same definition file

vbkick automatically reconfigure VM during runtime to use proper port mapping base on value of `ssh_host_port`
```
# in definition.cfg
ssh_host_port=${SSH_PORT:-2222}

# cmd line
$ SSH_PORT=2201 vbkick ssh vm_name1
$ SSH_PORT=2202 vbkick ssh vm_name2
```

useful to build multiple machines in the same time from the same definition file, e.g. to test various kickstart files
```
# in definition.cfg
kickstart_port=${KS_PORT:-7122}

# cmd line
$ KS_PORT=7101 vbkick ssh vm_name1
$ KS_PORT=7102 vbkick ssh vm_name2
```

Note1: if you build multiple machines in the same time make sure that boot media already exists, do not allow multiple machines download boot media to the same place in the same time.

Note2: if you use injection postinstall method don't forget update PORT value in kickstart file.

### source other definitions

useful to create hierarchy of definitions and don't repeate the same settings
```
# in definition-6.5-i386-desktop.cfg
. ./common.cfg
. ./common-desktop.cfg
...

# cmd line
$ ls
common.cfg
common-desktop.cfg
definition-6.5-i386-desktop.cfg
definition-6.5-x86_64-desktop.cfg
definition-6.5-x86_64-docker.cfg
definition-6.5-i386-noX.cfg
definition-6.5-x86_64-noX.cfg
definition-6.6-i386-noX.cfg
definition-6.6-x86_64-noX.cfg
```

### send something to stdin
useful to destroy the VM in noninteractive mode (otherwise vbkick ask you whether you are happy to continue)
```
echo "y" | vbkick destroy VM
```

### others

when virtualbox additions are installed you can use shared directory instead of transporting scripts to VM via SCP
```
# in definition.cfg
postinstall_launch=("cd /media/sf_vbkick/postinstall && sudo bash adm_postinstall.sh")
postinstall_transport=("")

# cmd line
$ vbkick postinstall vm_name
```

it may be convenient to download all boot media for all templates to the same place,

so that you can easily exclude this space from your backup policies
```
# in all definition files
boot_file_src_path="~/Downloads/ISOs"
```

ctrl-c is your friend - send SIGINT when you think vbkick did a job for you,

e.g.: kickstart file was successfully loaded by the VM (GET.. HTTP.. 200) then ctrl+c to stop vbkick as VM will be installed independently.
```
$ vbkick build sl6
[INFO] Loading "definition.cfg" definition...
Serving HTTP on 0.0.0.0 port 7122 ...
[INFO] webserver has been started (pid 3325)
[INFO] CHECKSUM:0ce79ca56c8d959cd81d068d1831c1975ac9d8bb8814fcbde444e7e8581e7029 is valid.
Virtual machine 'sl6' is created and registered.
UUID: ec6b5f6c-b28a-4e65-afce-48fd431ecc7f
Settings file: '/home/me/VirtualBox VMs/sl6/sl6.vbox'
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Disk image created. UUID: d44629d8-2c31-4a46-b6cd-9a26c6f61146
[INFO] VBoxManage sharedfolder add  "sl6" --name "vbkick" --hostpath "/home/me/git/vbkick/examples/SL6_lazy_method" --automount
Waiting for VM "sl6" to power on...
VM "sl6" has been successfully started.
[INFO] Sending keyboard scancodes:
[INFO] <Tab> text ks=http://10.0.2.2:7122/kickstart/scientificlinux-6.5-x86_64-lazy_noX.cfg<Enter>

[INFO] Waiting for ssh login with user vagrant to 127.0.0.1:2222 to work, kickstart_timeout=7200 sec
...................127.0.0.1 - - [10/May/2014 17:22:06] "GET /kickstart/scientificlinux-6.5-x86_64-lazy_noX.cfg HTTP/1.1" 200 -

...^C[INFO] Signal handler - cleanup before exiting... #<--- ctrl-c

[INFO] Stopping webserver (pid 3325)
[INFO] webserver was stopped
```

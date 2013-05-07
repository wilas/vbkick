#!/bin/bash

# The MIT License
#
# Copyright (c) 2013, Kamil Wilas (wilas.pl)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# Secure bash 
# (it also complain if you forget about required options in definition.cfg)
set -u;
shopt -s failglob;

# VM default settings
hostiocache="on"
cpu_count=1
memory_size=512
disk_size=10140
disk_format="vdi"
video_memory_size=10
# list of VM options: ("option1:value" "option2:value")
vm_options=("ioapic:on")

iso_sha256=""

boot_wait=10 #seconds
# list of boot_cmd
boot_cmd_sequence=()
# number of second wait between each boot_cmd
boot_seq_wait=1

kickstart_port=7122
kickstart_timeout=7200 #seconds

# by default gui enabled
gui_enabled=1
iso_path="iso"

# by default ssh keys enabled
ssh_keys_enabled=1
ssh_user="vbkick"
ssh_keys_path="keys"
ssh_priv_key="vbkick_key"
ssh_priv_key_src="https://raw.github.com/wilas/vbkick/master/keys/vbkick_key"
ssh_host_port="2222"
ssh_guest_port="22"
#ssh_login_timeout="7200"

# Other global variables
webserver_status=0
tmp_dir=""

# Display help
function usage {
    echo ""
    echo "Usage: $0 [build|destroy|export|validate|postinstall|help] VM_NAME"
    echo "Help create Virtualbox Guest and Vagrant boxes"
    echo ""
    echo "build                 build VM"
    echo "destroy               destroy VM"
    echo "export                export VM"
    echo "validate              validate VM, ssh needed"
    echo "postinstall           run postinstall scripts via ssh"
    echo "help                  display this help and exit"
    echo ""
}

# Cmd line parser, take 2 args
function process_args {
    local VM="${2}"
    case "$1" in
        "build") build_vm "${VM}" ;;
        "destroy") destroy_vm "${VM}" ;;
        "export") export_vm "${VM}" ;;
        "validate") validate_vm "${VM}" ;;
        "postinstall") lazy_postinstall "${VM}" ;;
        *) usage; exit ;;
    esac
}

# Load definition.cfg config file; it overwrite default settings
function load_definition {
    if [ -s "definition.cfg" ]; then 
        . "definition.cfg"
    else 
        echo "Not existing or empty definition.cfg file in `pwd`"
        echo "Terminating..." >&2
        exit 1
    fi
}

# Get virtualbox version
function get_vb_version {
    local version=$(VBoxManage --version) # e.g. 4.2.12r84980
    local version=${version%r*} #e.g. 4.2.12
    echo "${version}"
}

# Prepare installation media
function download_install_media {
    # check whether iso dir exist
    if [ ! -d "${iso_path}" ]; then
        echo "Creates iso directory"
        mkdir "${iso_path}"
    fi
    # check whether iso_file exist
    if [ ! -f "${iso_path}/${iso_file}" ]; then
        wget --no-check-certificate "${iso_src}" -O "${iso_path}/${iso_file}"
    fi
    # verify iso_src sha256sum
    local get_sha256=$(sha256sum ${iso_path}/${iso_file} | cut -d" " -f 1)
    if [[ "${iso_sha256}" != "${get_sha256}" ]]; then
        echo "WARNING: SHA256SUM is different then expected !"
        read -r -p "Do you want continue? [y/N]" ans
        if [[ ! $ans =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo "INFO: SHA256SUM:${iso_sha256} is valid."
    fi
    # check whether VBoxGuestAdditions exist
    if [ ! -f "${iso_path}/VBoxGuestAdditions_${vb_version}.iso" ]; then
        local additions_url="http://download.virtualbox.org/virtualbox/${vb_version}/VBoxGuestAdditions_${vb_version}.iso"
        wget --no-check-certificate "${additions_url}" -P "${iso_path}"
    fi
}

# Prepare ssh keys
function get_priv_ssh_key {
    # check whether keys dir exist
    if [ ! -d "${ssh_keys_path}" ]; then
        echo "Creates vbkick ssh keys directory"
        mkdir "${ssh_keys_path}"
    fi
    # check whether private key exist
    if [ ! -f "${ssh_keys_path}/${ssh_priv_key}" ]; then
        wget --no-check-certificate "${ssh_priv_key_src}" -O "${ssh_keys_path}/${ssh_priv_key}"
    fi
    # change ssh key permissions - too open private key will be ignored
    chmod 600 "${ssh_keys_path}/${ssh_priv_key}"
}

function build_vm {
    local VM=$1
    # check whether VM already exist
    VBoxManage list vms | grep -w "${VM}"
    # if VM exist previous cmd return 0
    if [ $? -eq 0 ]; then
        echo "${VM} already exist"
        exit 1
    fi
    # load vm description/definition
    load_definition
    # download iso files
    download_install_media
    # get ssh private key
    if [ $ssh_keys_enabled -eq 1 ]; then
        get_priv_ssh_key
    fi
    # create VM box with given settings
    create_box "${VM}"
    # start simple webserver (in background)
    start_web_server
    # host ip to connect from guest
    local host_ip=10.0.2.2
    # start VM
    if [ $gui_enabled -eq 1 ]; then
        VBoxManage startvm --type gui "${VM}"  && sleep $boot_wait
    else
        VBoxManage startvm --type headless "${VM}" && sleep $boot_wait
    fi
    # boot VM machine
    for boot_cmd in "${boot_cmd_sequence[@]}"; do
        boot_cmd=$(echo "${boot_cmd}" | sed -r "s/%IP%/$host_ip/g" | sed -r "s/%PORT%/$kickstart_port/g")
        echo "${boot_cmd}"
        # converts string to scancode via external python script
        local boot_cmd_code=$(printf "${boot_cmd}" | convert_2_scancode.py)
        # sends code to VM
        for code in $boot_cmd_code; do
            echo "${code}"
            if [ "${code}" == "wait" ]; then
                echo "waiting..."
                sleep 1
            else
                VBoxManage controlvm "${VM}" keyboardputscancode $code
                sleep 0.01
            fi
        done
        sleep $boot_seq_wait
    done
    # todo: wait until machine will be rebooted and ssh start working (before kickstart_timeout),
    # ssh_keys_enabled must be turn on to use that feature
    sleep $kickstart_timeout
    # stop webserver
    stop_web_server
    exit 0
}

function create_box {
    local VM=$1
    # register vm
    VBoxManage createvm --name "${VM}" --ostype "${os_type_id}" --register

    # create disk
    local location=$(VBoxManage list  systemproperties | grep "Default machine folder" | cut -d':' -f 2 | sed 's/^ *//g')
    VBoxManage createhd --filename "${location}/${VM}/${VM}.${disk_format}"\
    --size $disk_size --format "${disk_format}" --variant Standard

    # SATA controler - add hard disk
    VBoxManage storagectl "${VM}" --name "SATA Controller"\
    --add sata --hostiocache $hostiocache --sataportcount 1
    VBoxManage storageattach "${VM}" --storagectl "SATA Controller"\
    --port 0 --device 0 --type hdd --medium "${location}/${VM}/${VM}.${disk_format}"

    # IDE controler - add iso
    VBoxManage storagectl "${VM}" --name "IDE Controller" --add ide
    VBoxManage storageattach "${VM}" --storagectl "IDE Controller"\
    --type dvddrive --port 0 --device 0 --medium "${iso_path}/${iso_file}"
    VBoxManage storageattach "${VM}" --storagectl "IDE Controller"\
    --type dvddrive --port 1 --device 0 --medium "${iso_path}/VBoxGuestAdditions_${vb_version}.iso"

    # Tuning VM
    # setting cpu's
    VBoxManage modifyvm "${VM}" --cpus $cpu_count
    # setting memory size
    VBoxManage modifyvm "${VM}" --memory $memory_size
    # setting video memory size
    VBoxManage modifyvm "${VM}" --vram $video_memory_size
    # setting bootorder
    VBoxManage modifyvm "${VM}" --boot1 disk --boot2 dvd --boot3 none --boot4 none
    # other settings
    for option in "${vm_options[@]}"; do
        local key="${option%%:*}"
        local value="${option##*:}"
        VBoxManage modifyvm "${VM}" --"${key}" "${value}"
    done

    # ssh NAT mapping
    VBoxManage controlvm "${VM}" natpf1 "guestssh,tcp,,${ssh_host_port},,${ssh_guest_port}"
}

function destroy_vm {
    local VM=$1
    # check whether VM already exist
    VBoxManage list vms | grep -w "${VM}"
    # if VM exist previous cmd return 0
    if [ $? -ne 0 ]; then
        echo "${VM} doesn't exist"
        exit 1
    fi
    # check whether VM is running
    VBoxManage list runningvms | grep -w "${VM}"
    if [ $? -eq 0 ]; then
        echo "Poweroff ${VM}"
        VBoxManage controlvm "${VM}" poweroff
        sleep 1
    fi
    # destroy VM
    echo "Destroy ${VM}"
    read -r -p "Are you sure? [y/N]" ans
    if [[ $ans =~ ^[Yy]$ ]]; then
        echo "Destroying..."
        VBoxManage unregistervm "${VM}" --delete
    fi
    exit 0
}

function export_vm {
    #
    # basic replacement for that vagrant command:
    # vagrant package --base "${VM}" --output "${VM}.box"
    # if more customisation required use: vagrant package (--help)
    #
    local VM=$1
    # check whether VM_NAME.box exist in current dir
    if [ -f "${VM}.box" ]; then
        echo "${VM}.box already exist in `pwd`"
        exit 1
    fi
    # check whether VM exist
    VBoxManage list vms | grep -w "${VM}"
    # if VM exist previous cmd return 0
    if [ $? -ne 0 ]; then
        echo "${VM} doesn't exist"
        exit 1
    fi
    # check whether VM is running
    VBoxManage list runningvms | grep -w "${VM}"
    if [ $? -eq 0 ]; then
        echo "Poweroff ${VM}"
        VBoxManage controlvm "${VM}" poweroff
        # todo: consider shutdown using ssh and halt/poweroff cmd - nicer for OS...
        sleep 1
    fi
    # clearing previously set forwarded port
    VBoxManage modifyvm "${VM}" --natpf1 delete "guestssh"
    # create tmp_dir for export data
    tmp_dir=$(mktemp -d --tmpdir=.)
    # export VM to tmp_dir
    VBoxManage export "${VM}" --output "${tmp_dir}/box.ovf"
    # get VM MAC Address
    local mac_address=$(VBoxManage showvminfo --details --machinereadable "${VM}"\
    | grep macaddress1 | cut -d"=" -f 2)
    # add Vagrantfile
    printf "Vagrant::Config.run do |config|
    \t# This Vagrantfile is auto-generated by \`vagrant package\` to contain
    \t# the MAC address of the box. Custom configuration should be placed in
    \t# the actual \`Vagrantfile\` in this box.
    \tconfig.vm.base_mac = ${mac_address}
    \rend\n
    \r# Load include vagrant file if it exists after the auto-generated
    \r# so it can override any of the settings
    \rinclude_vagrantfile = File.expand_path(\"../include/_Vagrantfile\", __FILE__)
    \rload include_vagrantfile if File.exist?(include_vagrantfile)\n" > "${tmp_dir}/Vagrantfile"
    # create VM_NAME.box (gzip) file
    cd $tmp_dir && tar -cvzf "${VM}.box" * && cd ..
    mv "${tmp_dir}/${VM}.box" .
    # remove tmp_dir
    rm -rf $tmp_dir
    echo "Done: `pwd`/${VM}.box"
    exit 0
}

function validate_vm {
    # test already build VM - ssh needed
    # todo: test should be smart enought to check what I really want to test
    # e.g. If I don't need chef, don't test whether I have chef
    # todo: if no ssh then use root and password method - type pass ? or sshpass or expect
    echo "Not implemented yet"
    exit 1
}

function lazy_postinstall {
    # todo: run defined postinstall scripts via ssh
    # Example cmd:
    # ssh vbkick@localhost -t -i keys/vbkick_key -p 2222 -C 'sudo ifconfig'
    # ssh vbkick@localhost -t -i keys/vbkick_key -p 2222 -C 'mkdir -p ~/postinstall'
    # scp -P 2222 -i keys/vbkick_key postinstall/skrypt.sh vbkick@localhost:~vbkick
    # ssh vbkick@localhost -t -i keys/vbkick_key -p 2222 -C path/skrypt.sh
    echo "Not implemented yet"
    exit 1
}

function start_web_server {
    # start simple webserver serving files in background
    # todo: check whether port is not used by other proc.
    python -m SimpleHTTPServer $kickstart_port &
    # todo: ($?) check whether web server was really started - Exception ?
    # get the pid already spawned process, to kill it later
    web_pid=$!
    # update webserver_status variable
    webserver_status=1
}

function stop_web_server {
    # check whether webserver is running
    if [ $webserver_status -ne 0 ]; then
        echo "Stopping webserver..."
        kill $web_pid
        # check whether webserver proc was really killed
        if [ $? -eq 0 ]; then
            echo "INFO: webserver was stopped"
        else
            echo "WARNING: problem with stopping webserwer. Kill proces manually"
            ps aux | grep SimpleHTTPServer | grep -v grep
        fi
    fi
}

# (signals handler) - cleaning after ctr-c, etc. pressed
function clean_up {
    echo "INFO: Signal handler - cleanup before exiting..."
    # stop webserver
    stop_web_server
    # clean tmp_dir if exist
    if [ -d $tmp_dir ]; then
        rm -rf $tmp_dir
    fi
    exit 1
}

## MAIN ##
# exactly 2 Args required - ACTION VM_NAME
if [ $# -ne 2 ]; then
    usage
    exit 1
fi

vb_version=$(get_vb_version)
# signals handler
trap clean_up SIGHUP SIGINT SIGTERM
process_args "${1}" "${2}"


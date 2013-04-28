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
# src page: github.com/wilas/vmkick
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
vm_options=("ioapic:on") #list

iso_sha256=""

boot_wait=10 #seconds
boot_cmd_sequence=() #list
boot_seq_wait=1 #seconds

kickstart_port=7122
kickstart_timeout=3600 #seconds
#kickstart_file=""

# Other global variables
iso_path="iso"
webserver_status=0
#tmp_vagrant_box_dir="/tmp/vagrant_vbkick"

# Display help
function usage {
    echo ""
    echo "Usage: $0 [build|destroy|export|test|postinstall|help] VM_NAME"
    echo "Help create Virtualbox Guest and Vagrant .box"
    echo ""
    echo "build                 build VM"
    echo "destroy               destroy VM"
    echo "export                export VM"
    echo "test                  test VM, ssh needed"
    echo "postinstall           run postinstall scripts via ssh"
    echo "help                  display this help and exit"
    echo ""
}

# Cmd line parser, take 2 args
function process_args {
    local VM="${2}"
    case "$1" in
        build) build_vm "${VM}" ;;
        destroy) destroy_vm "${VM}" ;;
        export) export_vm "${VM}" ;;
        test) test_vm "${VM}" ;;
        postinstall) postinstall_tuning "${VM}" ;;
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
    local vb_version=$(VBoxManage --version) # e.g. 4.2.12r84980
    local vb_version=${vb_version%r*} #e.g. 4.2.12
    echo "${vb_version}"
}

# Prepare installation media
function download_install_media {
    # chec whether iso dir exist
    if [ ! -d "${iso_path}" ]; then
        echo "Creates iso directory"
        mkdir iso
    fi
    # check whether iso_file exist
    if [ ! -f "${iso_path}/${iso_file}" ]; then
        wget "${iso_src}" -O "${iso_path}/${iso_file}"
    fi
    # verify iso_src sha256sum
    local get_sha256=$(sha256sum ${iso_path}/${iso_file} | cut -d" " -f 1)
    if [[ "${iso_sha256}" != "${get_sha256}" ]]; then
        echo "WARNING: SHA256SUM is different then expected !"
    else
        echo "INFO: SHA256SUM:${iso_sha256} is valid."
    fi
    # check whether VBoxGuestAdditions exist
    if [ ! -f "${iso_path}/VBoxGuestAdditions_${vb_version}.iso" ]; then
        local additions_url="http://download.virtualbox.org/virtualbox/${vb_version}/VBoxGuestAdditions_${vb_version}.iso"
        # wget http://download.virtualbox.org/virtualbox/4.2.12/VBoxGuestAdditions_4.2.12.iso -P iso
        wget "${additions_url}" -P "${iso_path}"
    fi
}

function build_vm {
    local VM=$1
    # check whether VM already exist
    VBoxManage list vms | grep "${VM}"
    # if VM exist previous cmd return 0
    if [ $? -eq 0 ]; then
        echo "${VM} already exist"
        exit 1
    fi
    # load vm description/definition
    load_definition
    # download iso files if not exist
    download_install_media
    # create VM box with given settings
    create_box "${VM}"
    # start webserver (in background)
    start_web_server
    # host ip to connect from guest
    local host_ip=10.0.2.2
    # start VM
    # todo: gui or not ?
    VBoxManage startvm --type gui "${VM}"  && sleep $boot_wait
    #VBoxManage startvm --type headless "${VM}" && sleep $boot_wait
    # boot VM machine
    for boot_cmd in "${boot_cmd_sequence[@]}"; do
        boot_cmd=$(echo "${boot_cmd}" | sed -r "s/%IP%/$host_ip/g")
        boot_cmd=$(echo "${boot_cmd}" | sed -r "s/%PORT%/$kickstart_port/g")
        echo "${boot_cmd}"
        # converts string to scancode via external python script
        local boot_cmd_code=$(echo -en "${boot_cmd}" | convert_2_scancode.py)
        # sends code to VM
        for code in $boot_cmd_code; do
            echo "${code}"
            if [ "${code}" == "wait" ]; then
                echo "waiting..."
                sleep 1
            else
                VBoxManage controlvm "${VM}" keyboardputscancode $code
                sleep 0.05
            fi
        done
        sleep $boot_seq_wait
    done
    # todo: wait until machine will be rebooted and ssh start working (before kickstart_timeout)
    sleep $kickstart_timeout
    # stop webserver
    stop_web_server
}

function create_box {
    local VM=$1
    # register vm
    VBoxManage createvm --name "${VM}" --ostype "${os_type_id}" --register

    # create disk
    local location=$(VBoxManage list  systemproperties | grep "Default machine folder" | cut -d':' -f 2 | sed 's/^ *//g')
    echo "DEBUG: Location ---> ${location}"
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
    #VBoxManage controlvm "${VM}" natpf1 "guestssh,tcp,,${ssh_host_port},,${ssh_guest_port}"
    # todo: debug mode - display VM info
    #VBoxManage showvminfo "${VM}"
}

function destroy_vm {
    # check whether VM already exist
    VBoxManage list vms | grep "${VM}"
    # if VM exist previous cmd return 0
    if [ $? -ne 0 ]; then
        echo "${VM} doesn't exist"
        exit 1
    fi
    # check whether VM is running
    VBoxManage list runningvms | grep "${VM}"
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
}

function export_vm {
    echo "Not implemented yet"
    exit 1
    # vagrant 1.0: http://docs-v1.vagrantup.com/v1/docs/base_boxes.html
    # vagrant 1.1+: http://docs.vagrantup.com/v2/boxes/format.html
    #
    # check if $VM.box exist
    #ping - to check if VM is alive
    #VBoxManage controlvm "${VM}" poweroff 
    #or shoutdown using ssh and poweroff cmd - nicer for OS
    #wait on shutdown
    #mkdir tmp
    #VBoxManage export "${VM}" --output "${VM}.ovf" #in temp file
    #add Vagrantfile to temp
    #VBoxManage showvminfo --details --machinereadable "${VM}"
    #add metadata.json
    #gzip, tgz, tar
    #rm temp
    # INFO:
    #vagrant package --base SL64_box
    #vagrant box add my_box package.box
    #vagrant box list
}

function test_vm {
    echo "Not implemented yet"
    # todo: test should be smart enought to check what I really want to test
    # e.g. If I don't need chef, don't test whether I have chef
    exit 1
}

function postinstall_tuning {
    # tunning via ssh
    echo "Not implemented yet"
    exit 1
}

function start_web_server {
    # start simple webserver serving files in background
    #echo "Starting webserver... Listen: 0.0.0.0:${kickstart_port}"
    python -m SimpleHTTPServer $kickstart_port &
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
    echo "INFO: Signal handler - cleaning time"
    stop_web_server
    exit 1
}

## MAIN ##
# exactly 2 Args required - ACTION VM_NAME
if [ $# -ne 2 ]; then
    usage
    exit 1
fi

vb_version=$(get_vb_version)
# todo: update postinstall/adm_envrc with new VBOX_VERSION
# signals handler
trap clean_up SIGHUP SIGINT SIGTERM
process_args "${1}" "${2}"


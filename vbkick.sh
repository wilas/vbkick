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
# More about options: http://wiki.bash-hackers.org/commands/builtin/set
# treat unset variables as an error
# (it also complain if you forget about required options in definition.cfg)
set -u;
# exit when cmd fail (use ERR trap for clean exit)
set -e; set -E;
# fail the entire pipeline if any part of it fails
set -o pipefail;
# debug mode
#set -x;
# http://mywiki.wooledge.org/glob
shopt -s failglob;


# VM default settings - basic
hostiocache="on"
cpu_count=1
memory_size=512
disk_size=10140
disk_format="vdi"
video_memory_size=10
# list of VM options: ("option1:value" "option2:value")
vm_options=("ioapic:on")
# by default gui enabled
gui_enabled=1
# by default add shared folder - to disable: shared_folder=""
shared_folder="vbkick"

# ISO default settings
# default path to directory with iso files
iso_path="iso"
# by default sha256sum is empty - 
# WARNING is given during processing if sha256 sum is wrong (use: sha256sum --help)
iso_sha256=""

# Boot default settings
# default time before boot_cmd_sequence start
boot_wait=10
# list of boot_cmd: ("cmd1" "cmd2" "cmd3")
boot_cmd_sequence=("")
# default number of second wait between each boot_cmd
boot_seq_wait=1
# default webserver port to serve kickstart files
kickstart_port=7122
# default max webserver live time
kickstart_timeout=7200

# SSH default settings (veeded to run vbkick validate and/or lazy_posinstall)
# by default use ssh keys
ssh_keys_enabled=1
# default user
ssh_user="vbkick"
# default path to ssh keys
ssh_keys_path="keys"
# default private key name
ssh_priv_key="vbkick_key"
# default auto-download path 
ssh_priv_key_src="https://raw.github.com/wilas/vbkick/master/keys/vbkick_key"
# default ssh host port
ssh_host_port=2222
# default (22) ssh guest port to forwarding
ssh_guest_port=22
# default extra ssh and scp options
# UserKnownHostsFile - database file to use for storing the user host keys
# StrictHostKeyChecking - if "no" then automatically add new host keys to the host key database file
# you may consider editing ssh config: http://superuser.com/questions/141344/ssh-dont-add-hostkey-to-known-hosts
ssh_options="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# Lazy Postinstall default settings
# list of files and directories to transport to guest
postinstall_transport=("")
# list of postinstall commands
postinstall_launch=("")

# Other global variables - not use in definition.cfg (will be overwrite during program runtime)
# 0 - webserver is not running
webserver_status=0
# during exporting tmp directory is created
tmp_dir=""

# todo [MEDIUM]: future options:
#ssh_password="vbkick"
#ssh_login_timeout=7200
#iso_download_timeout=1800
#postinstall_timeout=1800
#sudo_cmd="sudo -S sh %s"
#shutdown_cmd="/sbin/halt -h -p"
# todo [LOW]: replace echo by printf

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
        # iso_src is empty (not defined)
        if [ -z "${iso_src}" ]; then 
            print "${iso_path}/${iso_file} not exist and iso_src is empty\n"
            exit 1
        fi
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
    if [[ `VBoxManage list vms | grep -w "${VM}"` ]]; then
        printf "${VM} already exist\n"
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
    # start simple webserver (in background)
    start_web_server
    # create VM box with given settings
    create_box "${VM}"
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
        if [ -z "${boot_cmd}" ]; then 
            continue
        fi
        boot_cmd=$(echo "${boot_cmd}" | sed -r "s/%IP%/$host_ip/g")
        boot_cmd=$(echo "${boot_cmd}" | sed -r "s/%PORT%/$kickstart_port/g")
        boot_cmd=$(echo "${boot_cmd}" | sed -r "s/%NAME%/${VM}/g")
        printf "${boot_cmd}\n"
        # converts string to scancode via external python script
        local boot_cmd_code=$(printf "${boot_cmd}" | convert_2_scancode.py)
        # sends code to VM
        for code in $boot_cmd_code; do
            #printf "${code}\n"
            if [ "${code}" == "wait" ]; then
                printf "waiting...\n"
                sleep 1
            else
                VBoxManage controlvm "${VM}" keyboardputscancode $code
                sleep 0.01
            fi
        done
        sleep $boot_seq_wait
    done
    # todo [MEDIUM]: wait until machine will be rebooted and ssh start working (before kickstart_timeout),
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
    if [[ ! `VBoxManage showvminfo "${VM}" | grep "vbkickSSH"` ]]; then
        VBoxManage controlvm "${VM}" natpf1 "vbkickSSH,tcp,,${ssh_host_port},,${ssh_guest_port}"
    fi

    # add shared folders
    if [ -n "${shared_folder}" ]; then 
        VBoxManage sharedfolder add  "${VM}" --name "${shared_folder}" --hostpath "`pwd`" --automount
    fi
}

function destroy_vm {
    local VM=$1
    # check whether VM already exist
    if [[ ! `VBoxManage list vms | grep -w "${VM}"` ]]; then
        echo "${VM} doesn't exist"
        exit 1
    fi
    # check whether VM is running
    if [[ `VBoxManage list runningvms | grep -w "${VM}"` ]]; then
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
    if [[ ! `VBoxManage list vms | grep -w "${VM}"` ]]; then
        echo "${VM} doesn't exist"
        exit 1
    fi
    # check whether VM is running 
    if [[ `VBoxManage list runningvms | grep -w "${VM}"` ]]; then
        echo "Poweroff ${VM}"
        VBoxManage controlvm "${VM}" poweroff
        # todo [MEDIUM]: shutdown VM using ssh and halt/poweroff cmd (nicer for OS)
        sleep 1
    fi

    # clearing previously set port forwarding rules (only if exist)
    if [[ `VBoxManage showvminfo "${VM}" | grep "vbkickSSH"` ]]; then
        VBoxManage modifyvm "${VM}" --natpf1 delete "vbkickSSH"
    fi
    
    # todo: rm shared folder (only if exist)
    # VBoxManage sharedfolder remove  "${VM}" --name "vbkick"

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
    # todo: add shared folder after exporting - only if exist prev.
    # todo: add NAT mapping after exporting - only if exist prev.
    echo "Done: `pwd`/${VM}.box"
    exit 0
}

function validate_vm {
    # test already build VM - ssh needed
    # todo [MEDIUM]: test should be smart enought to check what I really want to test
    # e.g. If I don't need chef, don't test whether I have chef
    # ssh vbkick@localhost -t -i keys/vbkick_key -p 2222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    echo "Not implemented yet"
    exit 1
}

function lazy_postinstall {
    local VM=$1
    # check whether VM is running 
    if [[ ! `VBoxManage list runningvms | grep -w "${VM}"` ]]; then
        printf "${VM} is not running...\n"
        exit 1
    fi
    # load vm description/definition
    load_definition

    # checking port forwarding (if no proper rules, try add new one for NAT mapping)
    if [[ ! `VBoxManage showvminfo "${VM}" | grep "NIC 1" | grep "host port = ${ssh_host_port}"\
        | grep "guest port = ${ssh_guest_port}"` ]]; then
        printf "NAT mapping - enable ssh port forwarding\n"
        VBoxManage controlvm "${VM}" natpf1 "vbkickSSH,tcp,,${ssh_host_port},,${ssh_guest_port}"
    fi

    # todo [LOW]: if ssh keys authentication is not enabled try login using password
    # (root, user, sshpass, expect, VBoxManage guestcontrol)

    if [ $ssh_keys_enabled -eq 1 ]; then        
        # if key not exist then get it
        get_priv_ssh_key
        # create path to ssh private key
        local key_path="${ssh_keys_path}/${ssh_priv_key}"

        # transport postinstall scripts to guest
        for pkt in "${postinstall_transport[@]}"; do
            if [ -z "${pkt}" ]; then 
                continue #consider break
            fi
            # check whether pkt is file or dir
            if [[ -d "${pkt}" ]]; then
                # pkt is directory
                scp -P $ssh_host_port -i "${key_path}" $ssh_options -r "${pkt}" "${ssh_user}@localhost:~${ssh_user}"
            elif [[ -f "${pkt}" ]]; then
                # pkt is file
                scp -P $ssh_host_port -i "${key_path}" $ssh_options "${pkt}" "${ssh_user}@localhost:~${ssh_user}"
            else
                # pkt is neither file nor directory
                printf "${pkt} is neither file nor directory\n"
                exit 1
            fi
        done

        # run postinstall commands via ssh
        for cmd in "${postinstall_launch[@]}"; do
            if [ -z "${cmd}" ]; then 
                continue #consider break
            fi
            echo "Exec: ${cmd}"
            ssh "${ssh_user}@localhost" -t -i ${key_path} -p $ssh_host_port $ssh_options -C "${cmd}"
        done
        # todo? [LOW]: clean after postinstall by rm transported media ?
    fi
    exit 0
}

function start_web_server {
    # check whether port is not used by other proc
    if [[ `nc -z localhost $kickstart_port` ]]; then
        echo "$kickstart_port port is already in use"
        exit 1
    fi
    # start simple webserver serving files in background
    python -m SimpleHTTPServer $kickstart_port &
    # get the pid already spawned process, to kill it later
    web_pid=$!
    sleep 2
    # check whether web server was really started
    if [[ ! `nc -z localhost $kickstart_port` ]]; then
        echo "webserver was not started"
        exit 1
    fi
    # update webserver_status variable
    webserver_status=1
}

function stop_web_server {
    # check whether webserver is running
    if [ $webserver_status -ne 0 ]; then
        printf "Stopping webserver...\n"
        # with "set -e -E" if kill command fail then ERR trap is processing 
        # simply execution of function is not continued
        kill $web_pid
        # kill command is sucessfull when SIGTERM is sent to running process
        # not when child process was really killed
        if [ ! `ps -ef | grep "python -m SimpleHTTPServer $kickstart_port" | grep -v grep` ]; then
            printf "INFO: webserver was stopped\n"
        else
            printf "WARNING: problem with stopping webserwer. Kill proces manually\n"
            ps -ef | grep "python -m SimpleHTTPServer $kickstart_port" | grep -v grep
        fi
        webserver_status=0
    fi
}

# (signals and error handler) - cleaning after ctr-c, etc.
function clean_up {
    echo "INFO: Signal/Error handler - cleanup before exiting..."
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

# check whether Virtualbox is installed - VBoxManage command exist
if [[ ! `which VBoxManage 2>/dev/null` ]]; then
    printf "VBoxManage command not exist - install Virtualbox or check your PATH\n"
    exit 1
fi
vb_version=$(get_vb_version)
# signals and error handler
trap clean_up SIGHUP SIGINT SIGTERM ERR
process_args "${1}" "${2}"


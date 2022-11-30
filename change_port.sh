#!/bin/bash

# Clearing promt after run this script.
clear
printf "
#######################################################################
#                   Tools For Change Port SSH                         #
#######################################################################
"
echo -e "\n"

# Check if user is root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script. \nScript Will exit in 5 Seconds\n"; sleep 5; exit 1; }


# Get OS Version and Play
play(){
    if [ -e "/etc/os-release" ]; then
    . /etc/os-release
    else
        echo "/etc/os-release does not exist!"
        kill -9 $$; exit 1;
    fi

    Platform=${ID,,}
    VERSION_ID=${VERSION_ID%%.*}
    if [[ "${Platform}" =~ ^centos$|^almalinux$|^rocky$|^fedora$ ]]; then
        RHEL_ver=${VERSION_ID}
        if [[ "${Platform}" =~ ^centos$ ]] && [ "${VERSION_ID}" == '8' ]; then
            sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
            sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
            echo -e "\n\nWe'll check update on your OS and Install some utilities\n"
            yum check-update
            yum install policycoreutils-python-utils -y
            echo -e "=====> changing port you want <=====\n"
            echo -e "=====>      please wait       <=====\n"
            semanage port -a -t ssh_port_t -p tcp $portbewant
            change_port
        else
            yum install policycoreutils-python-utils -y
            semanage port -a -t ssh_port_t -p tcp $portbewant
            change_port
        fi
    elif [[ "${Platform}" =~ ^debian$ ]]; then
        echo -e "=====> changing port you want <=====\n"
        echo -e "=====>      please wait       <=====\n"    
        change_port
    elif [[ "${Platform}" =~ ^ubuntu$ ]]; then
        echo -e "=====> changing port you want <=====\n"
        echo -e "=====>      please wait       <=====\n"    
        change_port
    else
        echo -e "\nSorry, Script does not support this OS."
        kill -9 $$; exit 1;
    fi
}

change_port(){
    # Create backup of current SSH config
    NOW=$(date +"%m_%d_%Y-%H_%M_%S")
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.inst.bckup.$NOW
    # Apply changes to sshd_config
    sed -i -e "s/#Port .*/Port $portbewant/g" /etc/ssh/sshd_config
    echo -e "\nRestarting SSH in 5 seconds. Please wait.\n"
    sleep 5
    # Restart SSH service
    service sshd restart
    echo ""
    echo -e "The SSH port has been changed to $portbewant. \nPlease login using that port to test BEFORE ending this session.\n"
    exit 1
}

# Ask port and then play it
read -p "Please input port SSH you want : " portbewant

if [[ "$portbewant" =~ ^[0-9]{2,5} || "$portbewant" == 22 ]]; then
    if [[ "$portbewant" -ge 1024 && "$portbewant" -le 65535 || "$portbewant" == 22 ]]; then
        play
    else
        echo -e "\nInvalid port: must be 22, or between 1024 and 65535.\n"
    fi
else
	echo -e "Invalid port: must be numeric!\n"
fi
#! /bin/bash

root_test(){
    error=$(tput bold setaf 1)
    under_line=$(tput smul)
    reset=$(tput sgr 0)
    if [ $EUID = 0 ]
    then
        grab_pack
    else
        echo "${error}CRITICAL ERROR${reset}: ${under_line}NOT ROOT USER, PLEASE RUN AS ROOT USER!${reset}";
        exit;
    fi
}

#Tests for the root user. NOTE: uses the $EUID variable to allow for use with sudo, doas, etc.

grab_pack(){
    sudo pacman -S kdialog archiso mkinitcpio --noconfirm;
    copy_relang;
}

#Grabs the packages required to make the iso.

copy_relang(){
    rm -rf ./flameos
    rm -rf ./work
    rm -rf ./temps
    cp -r /usr/share/archiso/configs/releng/ ./flameos
    package_def
}

#Clears the previous build directory and makes a new one.

package_def(){
    rm -rf ./flameos/packages.x86_64;
    rm -rf ./temps
    git clone https://github.com/TheTurnnip/flameos_package_list.git ./temps/packages;
    cp -rf ./temps/packages/packages.x86_64 ./flameos/packages.x86_64;
    systemd_enabler;
}

#Clones and copies the packages that are included in the iso.

systemd_enabler(){
    ln -s /usr/lib/systemd/system/sddm.service ./flameos/airootfs/etc/systemd/system/multi-user.target.wants/
    ln -s /usr/lib/systemd/system/NetworkManager.service ./flameos/airootfs/etc/systemd/system/multi-user.target.wants/
    auto_login
}

#Enables the systemd units that are used by the live iso.

auto_login(){
    mkdir ./flameos/airootfs/etc/sddm.conf.d/
    echo -e "[Autologin] \nUser=root \nSession=plasma" > ./flameos/airootfs/etc/sddm.conf.d/autologin.conf
    build
}

#Enables autologin for the live iso.

build(){
    mkarchiso -v -w ./work -o ./iso/ ./flameos
}

root_test

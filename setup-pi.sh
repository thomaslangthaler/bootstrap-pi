#!/bin/bash

# enable root login to bash
# TODO

# enable root login through ssh
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# start and enable sshd
systemctl start ssh
systemctl enable ssh

# install cryptsetup
apt install -y cryptsetup

# ensure cryptsetup is included in initramfs
# echo "CRYPTSETUP=y" >> /etc/cryptsetup-initramfs/conf-hook

# ensure Raspbian doesn't try to resume, creating a boot problem
# echo "RESUME=none" > /etc/initramfs-tools/conf.d/resume

# generate initramfs
# mkinitramfs -o /boot/initramfs.gz `uname -a | awk '{print $3}'`

# create a fakeroot to ensure mkinitramfs doesn't fuck up
dd if=/dev/urandom of=/tmp/key bs=1M count=1
dd if=/dev/zero of=/tmp/fakeroot.img bs=1M count=20
echo "YES" | cryptsetup luksFormat -h sha256 -s 256 -c aes-cbc-essiv:sha256 /tmp/fakeroot.img -v --key-file=/tmp/key
cryptsetup luksOpen /tmp/fakeroot.img crypt --key-file=/tmp/key
mkfs.ext4 /dev/mapper/crypt

# make necessary changes for system to boot from encrypted root
echo "initramfs initramfs.gz followkernel" >> /boot/config.txt
sed -i.bak -E "s/\broot=PARTUUID=[^ ]+/root=\/dev\/mapper\/crypt cryptdevice=\/dev\/mmcblk0p2:crypt/" /boot/cmdline.txt
sed -i.bak -E "s/^PARTUUID[^ ]+\s+\/\s+/\/dev\/mapper\/crypt  \/  /" /etc/fstab
echo "crypt  /dev/mmcblk0p2  none  luks,initramfs" >> /etc/crypttab

# generate initramfs
# update-initramfs -u
mkinitramfs -o /boot/initramfs.gz `uname -a | awk '{print $3}'`

#!/bin/bash

set -e

TARGET_DRIVE=${1}

# unmount automounted partitions
umount "${TARGET_DRIVE}1"
umount "${TARGET_DRIVE}2"

# create local mount directories
mkdir -p pi/mount
mkdir pi/backup
mkdir pi/encrypted

# mount the rootfs, rsync to backup and umount
mount "${TARGET_DRIVE}2" pi/mount
rsync -avh pi/mount/* pi/backup
umount "${TARGET_DRIVE}2"

START=`fdisk -l "${TARGET_DRIVE}" | grep "${TARGET_DRIVE}2" | awk '{print $2}'`

# delete root partition, reformat it with luks
echo -en "d\n2\nn\np\n2\n$START\nY\nw\n" | fdisk $TARGET_DRIVE

cryptsetup luksFormat -h sha256 -s 256 -c aes-cbc-essiv:sha256 "${TARGET_DRIVE}2"
cryptsetup luksOpen "${TARGET_DRIVE}2" crypt
mkfs.ext4 /dev/mapper/crypt
mount /dev/mapper/crypt pi/encrypted

# rsync contents of root partition back to encrypted partition
rsync -avh pi/backup/* pi/encrypted

# umount and close encrypted partition
umount pi/encrypted
cryptsetup luksClose crypt
sync

# remove temporary folders
rm -rf pi

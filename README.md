# bootstrap-pi

Instructions on bootstrapping an encrypted Raspberry Pi

Based on instructions found [here](https://carlo-hamalainen.net/2017/03/12/raspbian-with-full-disk-encryption/)

* Download latest Raspbian and flash it to SD card
* Boot, install cryptsetup
* Ensure cryptsetup is included in initramfs (CRYPTSETUP=y in /etc/cryptsetup-initramfs/conf-hook)
* Create, luksFormat, luksOpen and mount as ext4 /tmp/fakeroot.img with same mapper as intended for /
* Make changes to /boot/cmdline.txt, /boot/config.txt, /etc/fstab, /etc/crypttab
* Enable SSH
* Create initramfs
* Remove SD card, mount on host
* Mount unencrypted root partition, rsync out contents
* Reformat root partition, encrypt
* Mount encrypted root, rsync back contents
* Profit

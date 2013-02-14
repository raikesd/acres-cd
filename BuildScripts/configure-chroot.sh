#!/bin/bash
#-------------------------------------------------------------------------
#	File:	BuildScripts/configure-chroot.sh
#	Author:	Donald Raikes <don.raikes@gmail.com>
#	Date:	02/11/2013
#-------------------------------------------------------------------------
echo "running configure-chroot.sh ..."
sudo mount none -t proc /proc
sudo mount none -t sysfs /sys
sudo mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

sudo apt-get update
sudo apt-get install -y -qq dbus
dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
sudo apt-get install -y -qq \
	ubuntu-standard \
	casper \
	lupin-casper \
	discover \
	laptop-detect \
	os-prober \
	linux-generic

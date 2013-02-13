# ---------------------------------------------------------------------
#	File:	acres-cd/Makefile
#	Author:	Donald Raikes <don.raikes@gmail.com>
#	Date:	02/08/2013
# ---------------------------------------------------------------------

# script properties
DT=`date +%Y%m%d`
CWD=`pwd`
SCRIPTDIR=$(CWD)/scripts
CONFDIR=$(CWD)/conf

WORKDIR=~/acres/$(DT)
CHROOTDIR=$(WORKDIR)/chroot
IMAGEDIR=$(WORKDIR)/image
BOOTDIR=$(IMAGEDIR)/boot
CASPERDIR=$(IMAGEDIR)/casper
ISOLINUXDIR=$(IMAGEDIR)/isolinux
INSTALLDIR=$(IMAGEDIR)/install
## various package sets:

syntax:
	echo "Syntax:"
	echo "    make build-cd		-		to build the cd"
	echo .
	echo "The cd is based on ubuntu 13.04 Raring Ringtail."

update-host:
	echo "Updating host system with necessary packages ... "
	$(PATUPDATE)
	sudo apt-get update
	sudo apt-get install -y -qq debootstrap genisoimage squashfs-tools syslinux

mkdirs: | cleanup
	# Now prepare the directory structure
	echo "Preparing the directory structure in $(WORKDIR) ..."
	sudo mkdir -p $(CHROOTDIR) 
	sudo mkdir -p $(BOOTDIR) 
	sudo mkdir -p $(CASPERDIR) 
	sudo mkdir -p $(ISOLINUXDIR)
	sudo mkdir -p $(INSTALLDIR)

cleanup:
	# remove old directory structure if it exists already
	echo "Cleaning up old directory structure $(WORKDIR) ..."
	sudo rm -fr $(WORKDIR)

bootstrap: | update-host mkdirs
	echo "Bootstrap the base image ..."
	sudo debootstrap --arch=i386 raring $(CHROOTDIR)

mount: 
	# mount necessary block devices
	echo "Running mount: ..."
	sudo mount --bind /dev $(CHROOTDIR)/dev

copyfiles:
	# copy necessary files into the chroot directory.
	echo "Copying files ..."
	sudo cp /etc/hosts $(CHROOTDIR)/etc
	sudo cp /etc/resolv.conf $(CHROOTDIR)/etc
	sudo cp /etc/apt/sources.list $(CHROOTDIR)/etc/apt
	sudo cp $(SCRIPTDIR)/* $(CHROOTDIR)/root

prep: |  bootstrap mount copyfiles
	# Prepare the chroot environment:
	echo "chroot environment has been prepared and now you will be placed inside of a chroot."
	echo "Run /root/customize-cd.sh to install extra packages."
	echo "Remember to run /root/cleanup-chroot.sh before exiting the chroot."
	sudo chroot $(CHROOTDIR)

start-chroot:
	# chroot into the cd image chroot
	echo "Chrooting $(CHROOTDIR) ... "
	sudo chroot $(CHROOTDIR)

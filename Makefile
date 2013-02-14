########################################################
#	File:	Makefile
#	Author:	Donald Raikes <don.raikes@gmail.com>
#	Date:	02/13/2013
########################################################

# set makefile properties
DT=`date +%Y%m%d`
CWD=`pwd`
BUILDSCRIPTS=$(CWD)/BuildScripts
USERSCRIPTS=$(CWD)/UserScripts
WORKDIR=~/acres/$(DT)
CHROOTDIR=$(WORKDIR)/chroot
IMAGEDIR=$(WORKDIR)/image
CASPERDIR=$(IMAGEDIR)/casper
BOOTDIR=$(IMAGEDIR)/boot
ISOLINUXDIR=$(IMAGEDIR)/isolinux
INSTALLDIR=$(IMAGEDIR)/install

FROMSERIES=precise
TOSERIES=raring

Cleanup:
	# remove the working directory structure if it exists.
	echo "Running Cleanup:..."
	test -d $(WORKDIR); sudo rm -fr $(WORKDIR)

Make-Dirs: | Cleanup
	# Create a new directory structure.
	echo "Running Make-Dirs: ..."
	sudo mkdir -p $(CHROOTDIR) $(BOOTDIR) $(CASPERDIR) $(ISOLINUXDIR) $(INSTALLDIR)

Update-Host:
	# update host system with necessary packages.
	echo "Running Update-Host: ... "
	sudo apt-get update -qq > /dev/null
	sudo apt-get install -y -qq debootstrap syslinux squashfs-tools genisoimage

Bootstrap: | Make-Dirs Update-Host
	# Run debootstrap to bootstrap the new system image.
	echo "Running Bootstrap: ..."
	sudo debootstrap --arch=i386 $(TOSERIES) $(CHROOTDIR)

Setup-Networking:
		# copy hosts and resolv.conf files from host to chroot 
		echo "Running Setup-Networking: ... "
		sudo cp /etc/hosts $(CHROOTDIR)/etc/hosts
		sudo cp /etc/resolv.conf $(CHROOTDIR)/etc/resolv.conf

Configure-APT:
	# Configure the /etc/apt/sources.list file for the chrooted system.
	echo "Running Configuring-apt: ... "
	sudo chmod 777 $(CHROOTDIR)/etc/apt/sources.list
	sudo sed s/$(FROMSERIES)/$(TOSERIES)/ < /etc/apt/sources.list > $(CHROOTDIR)/etc/apt/sources.list

Copy-Build-Scripts:
	# copy the scripts necessary to customize the chroot environment into the chroot folder
	echo "Running Copy-Build-Scripts: ... "
	test -d $(CHROOTDIR)/usr/local/bin; sudo cp $(BUILDSCRIPTS)/* $(CHROOTDIR)/usr/local/bin
	sudo chmod 777 $(CHROOTDIR)/usr/local/bin/*

Update-Chroot: | Copy-Build-Scripts
	# update the chroot environment with necessary packages.
	echo "Running Update-Chroot: ... "
	sudo chroot $(CHROOTDIR) /usr/local/bin/update-chroot.sh

Add-Accessibility: | Copy-Build-Scripts
	# add accessibility features
	echo "Running Add-Accessibility: ... "
	sudo chroot $(CHROOTDIR) /usr/local/bin/add-accessibility.sh

System-Rescue: | Copy-Build-Scripts
	# add packages for basic system rescue
	echo "running System-Rescue: ..."
	sudo chroot $(CHROOTDIR) /usr/local/bin/system-rescue.sh


Customize-Chroot: | Bootstrap Setup-Networking Configure-APT Copy-Build-Scripts
	# Now chroot into the newly bootstrapped system and customize it using the build scripts.
	echo "Running Customize-Chroot: ... "

#!/bin/bash
#----------------------------------------------------------------
#	File:	BuildScripts/add-accessibility.sh
#	Author:	Donald Raikes <don.raikes@gmail.com>
#	Date:	02/14/2013
#----------------------------------------------------------------
echo "running add-accessibility.sh"
sudo apt-get install -y -qq \
	brltty \
	espeakup \
	espeak \speakup \
	speakup-tools \
	alsa \
	alsa-utils

# now setup brltty to load automatically:
echo "Setting up brltty to start automatically..."
perl -pi -e 's/=no/=yes/g' /etc/default/brltty
update-initramfs -u

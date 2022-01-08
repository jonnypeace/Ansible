#!/bin/bash

# on first launch the sha file won't exist, so will recreate a container regardless.
# once the script has run once, sha file will be created and script will ignore
# updates if the image exists on system. Personalize shafile variable/directory
# to meet your needs and docker storage volume location.

shafile='/home/user/heimsha.txt'

oldsha=`cat $shafile`
newsha=$(docker pull ghcr.io/linuxserver/heimdall | grep sha256 | awk '{print $2}' | awk -F ':' '{print $2}')

if [[ $oldsha == $newsha ]]
then
	echo 'Image used is  already latest version'
	exit 0
else
	docker pull ghcr.io/linuxserver/heimdall | grep sha256 | awk '{print $2}' | awk -F ':' '{print $2}' > $shafile

	answer=$(docker ps -a | grep heimdall | awk '{print $1}')
	echo "Container $answer will be removed, and a new container will be created"

	docker stop $answer 

	docker container rm $answer

	docker pull ghcr.io/linuxserver/heimdall

	docker run -d \
	  --name=heimdall \
	  -e PUID=1000 \
	  -e PGID=1000 \
	  -e TZ=Europe/London \
	  -p 80:80 \
	  -p 443:443 \
	  -v /home/user/Heimdall:/config \
	  --restart unless-stopped \
	  ghcr.io/linuxserver/heimdall

	if [[ $? != 0 ]]; then
	echo 'error occured trying to run docker'; else
	echo "Docker Container Updated"
	fi
fi

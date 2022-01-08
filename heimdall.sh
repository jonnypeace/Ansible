#!/bin/bash

oldsha=`cat /home/jonny/heimsha.txt`
newsha=$(docker pull ghcr.io/linuxserver/heimdall | grep sha256 | awk '{print $2}' | awk -F ':' '{print $2}')
echo $oldsha old
echo $newsha new

if [[ $oldsha == $newsha ]]
then
	echo 'Image used is  already latest version'
	exit 0
else
	docker pull ghcr.io/linuxserver/heimdall | grep sha256 | awk '{print $2}' | awk -F ':' '{print $2}' > /home/jonny/heimsha.txt

	answer=$(sudo docker ps -a | grep heimdall | awk '{print $1}')
	echo "Container $answer will be removed, and a new container will be created"

	sudo docker stop $answer 

	sudo docker container rm $answer

	sudo docker pull ghcr.io/linuxserver/heimdall

	sudo docker run -d \
	  --name=heimdall \
	  -e PUID=1000 \
	  -e PGID=1000 \
	  -e TZ=Europe/London \
	  -p 80:80 \
	  -p 443:443 \
	  -v /home/jonny/Heimdall:/config \
	  --restart unless-stopped \
	  ghcr.io/linuxserver/heimdall

	if [[ $? != 0 ]]; then
	echo 'error occured trying to run docker'; else
	echo "Docker Container Updated"
	fi
fi

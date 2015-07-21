#!/bin/sh

set -e

day=4
day="Day$(printf '%03d' $day)"

#/Users/tom/GitHub/KitchenSync/KitchenSync.sh \
#	--auto-folder-naming "/Day003_$(date +'%Y%m%d')/Offload" \
#	/Volumes/EOS_DIGITAL/DCIM/100EOS5D \
#	/Users/tom/Documents/Temp
#	

/Users/tom/GitHub/KitchenSync/KitchenSync.sh \
	--auto-folder-naming "/$day/Offload" \
	/Volumes/EOS_DIGITAL/DCIM/100EOS5D \
	/Users/tom/Documents/Temp


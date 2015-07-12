#!/bin/bash

#####
#
# Script to copy material (files and folders) from source folder
# to one or more destination folders using rSync
#
#####

logfile="$HOME/Library/Logs/rSyncScript/rSyncScript$(date +_%Y_%m_%d_%H_%M_%S).log"

mkdir -p "$HOME/Library/Logs/rSyncScript"


# Flags
#  Include hidden files
#  Verbose
#  Automatic target folder naming e.g. Date/Offload_%n
#  No checksum
#  Checksums only

source=$1
shift

for copy in "$@" ; do
	copies=( "${copies[@]}" "$copy" )
	shift
done

for (( i = 0 ; i < ${#copies[@]} ; i++ )); do
	
	echo "Copy $(($i + 1)) of ${#copies[@]}" | tee -a $logfile
	
	#rSync -rt -h -vi --exclude=".*" --log-file="$logfile" --log-file-format="%f" "$source" "${copies[$i]}"
	rSync -rt -h -vi --exclude=".*" "$source" "${copies[$i]}"

	echo "Copy $(($i + 1)) of ${#copies[@]} complete" | tee -a $logfile
	
	if [ $i -eq 0 ]; then
		echo "First copy complete - source can be ejected"
		
		# Do the remaining copies from the first copy
		source="${copies[0]}"
	fi

done

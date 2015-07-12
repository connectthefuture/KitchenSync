#!/bin/bash

#find -s * -type f -exec md5 "{}" \; > md5sum.txt

#find -s * -type f -exec md5 -r "{}" \;

if [ $# -lt 1 ] ; then
	echo "You must specify at least one file or path" >&2
	exit 1
fi

for i in "$@" ; do
	
	if [ -f "$i" ]; then
		
		md5 -r "$i"
		
	elif [ -d "$i" ]; then

		cd "$i"
		find -s * -type f -not -name ".*" -exec md5 -r "{}" \;

	fi
done

#!/bin/bash

copy()
{
	if [ $# -ne 3 ] ; then
		echo "Usage: $0 source target include_hidden" >&2
		return 1
	fi
	
	source="$1"
	target="$2"
	include_hidden="$3"

	echo "Starting copy: ""$source"" -> ""$target"
	sleep $(($RANDOM % 10 + 10))
	echo "Finished copy: ""$source"" -> ""$target"
}

get_checksums()
{
	if [ $# -ne 3 ] ; then
		echo "Usage: $0 path include_hidden log" >&2
		return 1
	fi
	
	path="$1"
	include_hidden="$2"
	log="$3"
	
	echo "Starting checksums: ""$path"" - log: ""$log"
	sleep $(($RANDOM % 10 + 10))
	echo "Finished checksums: ""$path"
}

source="source"
copies[0]="copy1"
copies[1]="copy2"
copies[2]="copy3"

copy "$source" "${copies[0]}" 0
get_checksums "$source" 0 "md5_source.txt" &
get_checksums "${copies[0]}" 0 "md5_copy1.txt" &

source="${copies[0]}"

for (( i = 1 ; i < ${#copies[@]} ; i++ )); do
	{
		copy "$source" "${copies[i]}" 0
		get_checksums "${copies[i]}" 0 "md5_copy"$(($i+1))".txt"
	} &
done

wait

echo "Compare checksum files"
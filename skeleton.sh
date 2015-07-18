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

info()
{
	if [ $# -ne 5 ] ; then
		echo "Usage: $0 source targets include_hidden verify_files verify_only" >&2
		return 1
	fi
	
	source="$1"
	copies="$2"
	include_hidden="$3"
	verify_files="$4"
	verify_only="$5"
	
	echo
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo "+"
	echo "+    ============"
	echo "+    kitchen-sync"
	echo "+    ============"
	echo "+"
	if [ $include_hidden = 1 ] ; then
		echo "+    include hidden files"
	else
		echo "+    exclude hidden files"
	fi
	if [ $verify_only = 1 ] ; then
		echo "+    verify only"
	else
		echo "+    copy"
	fi
	if [ $verify_files = 0 ] ; then
		echo "+    don't verify"
	else
		echo "+    verify"
	fi
	echo "+"
	echo "+    source: $source"
	for (( i = 0 ; i < ${#copies[@]} ; i++ )); do
		echo "+    copy "$(($i+1))": ${copies[i]}"
	done
	echo "+"
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo
}

source="source"
copies[0]="copy1"
copies[1]="copy2"
copies[2]="copy3"

INCLUDE_HIDDEN=0
VERIFY_FILES=1
VERIFY_ONLY=0

info "$source" $copies $INCLUDE_HIDDEN $VERIFY_FILES $VERIFY_ONLY

copy "$source" "${copies[0]}" $INCLUDE_HIDDEN
get_checksums "$source" $INCLUDE_HIDDEN "md5_source.txt" &
get_checksums "${copies[0]}" $INCLUDE_HIDDEN "md5_copy1.txt" &

source="${copies[0]}"

for (( i = 1 ; i < ${#copies[@]} ; i++ )); do
	{
		copy "$source" "${copies[i]}" $INCLUDE_HIDDEN
		get_checksums "${copies[i]}" $INCLUDE_HIDDEN "md5_copy"$(($i+1))".txt"
	} &
done

wait

echo
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+"
echo "+    Compare checksum files"
echo "+"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo

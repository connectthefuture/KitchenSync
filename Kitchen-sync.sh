#!/bin/bash

log_folder="$HOME""/Library/Logs/kitchen-sync/$(date +%F)"
#log_file="$log_folder""/log.txt"
mkdir -p "$log_folder"

do_copy()
{
	if [ $# -ne 3 ] ; then
		echo "Usage: $0 source target include_hidden" >&2
		return 1
	fi
	
	source="$1"
	target="$2"
	include_hidden="$3"
	
	echo "Copy $source to $target"
	
	command="rSync -rt"
	if [ $include_hidden = 0 ] ; then
		command="$command --exclude=\".*\""
	fi
	command="$command $source $target"
	
	#echo "$command"
	eval "$command"
}

get_checksums()
{
	if [ $# -ne 3 ] ; then
		echo "Usage: $0 path include_hidden log" >&2
		return 1
	fi
	
	path="$1"
	include_hidden="$2"
	log_file="$3"
	
	echo "Checksums for $path"

	cd "$path"
	
	command="find -s * -type f"
	if [ $include_hidden = 0 ] ; then
		command="$command -not -name \".*\""
	fi
	command="$command -exec md5 -r \"{}\" \; >> ""$log_file"
	
	#echo "$command"
	eval "$command"
}

PROGNAME="$(basename "$0")"

usage()
{
	if [ "$*" != "" ] ; then
		echo "Error: $*"
	fi

    cat << EOF
Usage: $PROGNAME [OPTION ...] [source] [target] [target ...]

Recursively copy files from source to one or more destinations,
performing checksums to verify target matches source.

Options
 -h, --help          display this usage message and exit
 --no-checksums      don't verify files with checksums
 --checksums-only    just compare directories with checksums
 --include-hidden    include hidden files (those starting with a '.')
EOF

	exit 1
}

VERIFY_FILES=1
CHECKSUMS_ONLY=0
INCLUDE_HIDDEN=0

source=""
copies=()
while [ $# -gt 0 ] ; do
	case "$1" in
    -h|--help)
        usage
        ;;
    --no-checksums)
        VERIFY_FILES=0
        ;;
    --include-hidden)
        INCLUDE_HIDDEN=1
        shift
        ;;
    --checksums-only)
        CHECKSUMS_ONLY=1
        shift
        ;;
    -*)
        usage "Unknown option '$1'"
        ;;
    *)
    	if [ -z "$source" ]; then
    		source="$1/"
		else
			copies=("${copies[@]}" "$1/")
    	fi
        ;;
    esac
    shift
done

if [ ${#copies[@]} -lt 1 ] ; then
	usage
fi

# Create checksum log file names
checksum_logs=()
checksum_logs=("${checksum_logs[@]}" "$log_folder/md5-source.log")
for (( i = 0 ; i < ${#copies[@]} ; i++ )); do
	checksum_logs=("${checksum_logs[@]}" "$log_folder/md5-copy"$(($i+1))".log")
done

do_copy "$source" "${copies[0]}" $INCLUDE_HIDDEN
get_checksums "$source" $INCLUDE_HIDDEN "${checksum_logs[0]}" &
get_checksums "${copies[0]}" $INCLUDE_HIDDEN "${checksum_logs[1]}" &

for (( i = 1 ; i < ${#copies[@]} ; i++ )); do
	{
		do_copy "${copies[0]}" "${copies[i]}" $INCLUDE_HIDDEN
		get_checksums "${copies[i]}" $INCLUDE_HIDDEN "${checksum_logs[i+1]}"
	} &
done

wait

for (( i = 1 ; i < ${#checksum_logs[@]} ; i++ )); do
	echo "Compare ${checksum_logs[0]} to ${checksum_logs[i]}"
	diff "${checksum_logs[0]}" "${checksum_logs[i]}"
done

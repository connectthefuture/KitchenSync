#!/bin/bash
set -e

PROGNAME="$(basename "$0")"
log_folder="$HOME/Library/Logs/$PROGNAME/$(date +%F)"

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
	
	mkdir -p "$target"
	
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
	echo "  kitchen-sync"
	echo ""
	echo "    options:"
	if [ $verify_only = 1 ] ; then
		echo "      verify only"
	else
		echo "      copy"
	fi
	if [ $verify_files = 0 ] ; then
		echo "      don't verify"
	else
		echo "      verify"
	fi
	if [ $include_hidden = 1 ] ; then
		echo "      include hidden files"
	else
		echo "      exclude hidden files"
	fi
	echo ""
	echo "    folders:"
	echo "      source: $source"
	for (( i = 0 ; i < ${#copies[@]} ; i++ )); do
		echo "      copy "$(($i+1))": ${copies[i]}"
	done
	echo
	echo "    copy/verify:"
}

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
VERIFY_ONLY=0
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
        ;;
    --checksums-only)
        VERIFY_ONLY=1
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

if [ ! -d "$source" ] ; then
	echo "Source is not a directory"
	usage
fi

if [ ${#copies[@]} -lt 1 ] ; then
	echo "Must specify source and destination directories"
	usage
fi

info "$source" $copies $INCLUDE_HIDDEN $VERIFY_FILES $VERIFY_ONLY

# Create checksum log file names
if [ $VERIFY_FILES = 1 ] ; then
	checksum_logs=()
	checksum_logs=("${checksum_logs[@]}" "$log_folder/md5-source.log")
	for (( i = 0 ; i < ${#copies[@]} ; i++ )); do
		checksum_logs=("${checksum_logs[@]}" "$log_folder/md5-copy"$(($i+1))".log")
	done
fi

# Do the 1st copy
if [ $VERIFY_ONLY = 0 ] ; then
	do_copy "$source" "${copies[0]}" $INCLUDE_HIDDEN
fi
if [ $VERIFY_FILES = 1 ] ; then
	get_checksums "$source" $INCLUDE_HIDDEN "${checksum_logs[0]}" &
	get_checksums "${copies[0]}" $INCLUDE_HIDDEN "${checksum_logs[1]}" &
fi

# Do subsequent copies
for (( i = 1 ; i < ${#copies[@]} ; i++ )); do
	{
		if [ $VERIFY_ONLY = 0 ] ; then
			do_copy "${copies[0]}" "${copies[i]}" $INCLUDE_HIDDEN
		fi
		if [ $VERIFY_FILES = 1 ] ; then
			get_checksums "${copies[i]}" $INCLUDE_HIDDEN "${checksum_logs[i+1]}"
		fi
	} &
done

wait

# Compare checksum logs
if [ $VERIFY_FILES = 1 ] ; then
	for (( i = 1 ; i < ${#checksum_logs[@]} ; i++ )); do
		echo "Compare ${checksum_logs[0]} to ${checksum_logs[i]}"
		diff "${checksum_logs[0]}" "${checksum_logs[i]}"
	done
fi

#trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
trap "exit" INT TERM
trap "kill 0" EXIT

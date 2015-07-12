#!/bin/bash

logfile="$HOME/Library/Logs/Kitchen-sync/Kitchen-sync$(date +_%Y_%m_%d_%H_%M_%S).log"

mkdir -p "$HOME/Library/Logs/Kitchen-sync"

get_checksums()
{
	if [ $# -ne 1 ] ; then
		echo "Usage: $0 path" >&2
		return 1
	fi
	
	include_hidden=0
	log_file=""
	
	find -s * -type f -not -name ".*" -exec md5 -r "{}" \;
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
    		source="$1"
		else
			copies=("${copies[@]}" "$1")
    	fi
        ;;
    esac
    shift
done

if [ ${#copies[@]} -lt 1 ] ; then
	usage
fi

#cat << EOF
#VERIFY_FILES=$VERIFY_FILES
#CHECKSUMS_ONLY=$CHECKSUMS_ONLY
#INCLUDE_HIDDEN=$INCLUDE_HIDDEN
#EOF

#for copy in "$@" ; do
#	copies=( "${copies[@]}" "$copy" )
#	shift
#done

num_copies=${#copies[@]}

for (( i = 0 ; i < ${#copies[@]} ; i++ )); do
	
	echo "Copy $(($i + 1)) of $num_copies" | tee -a $logfile
	
	#rSync -rt -h -vi --exclude=".*" --log-file="$logfile" --log-file-format="%f" "$source" "${copies[$i]}"
	rSync -rt --exclude=".*" "$source" "${copies[$i]}"

	echo "Copy $(($i + 1)) of $num_copies complete" | tee -a $logfile

	if [ "$VERIFY_FILES" = 1]; then
		if [ $i -eq 0 ]; then
			cd "$source"
			find -s * -type f -not -name ".*" -exec md5 -r "{}" \;
		fi
		
		cd "${copies[$i]}"
		find -s * -type f -not -name ".*" -exec md5 -r "{}" \;
	fi
	
	if [ $i -eq 0 ]; then
		#echo "First copy complete - source can be ejected"
		
		# Do the remaining copies from the first copy
		source="${copies[1]}"
	fi

done

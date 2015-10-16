#!/bin/bash
set -e

PROGNAME="$(basename "$0")"
log_folder="$HOME/Library/Logs/$PROGNAME"

info()
{
	if [ $# -ne 6 ] ; then
		echo "Usage: $0 source targets include_hidden verify_files verify_only auto_folder_naming" >&2
		return 1
	fi
	
	source="$1"
	copies="$2"
	include_hidden="$3"
	verify_files="$4"
	verify_only="$5"
	auto_folder_naming="$6"
	
	echo "  $PROGNAME"
	echo ""
	echo "    options:"
	if [ $verify_only = 1 ] ; then
		echo "      verify only"
	#else
	#	echo "      copy"
	fi
	if [ $verify_files = 0 ] ; then
		echo "      don't verify"
	#else
	#	echo "      verify"
	fi
	if [ $include_hidden = 1 ] ; then
		echo "      include hidden files"
	#else
	#	echo "      exclude hidden files"
	fi
	if [ $auto_folder_naming = 1 ] ; then
		echo "      auto destination folder naming"
	fi
	echo ""
	echo "    folders:"
	echo "      source: $source"
	for (( i = 0 ; i < ${#copies[@]} ; i++ )); do
		echo "      copy "$(($i+1))": ${copies[i]}"
	done
	echo
	echo "    copy/verify:"
    echo " End of info function"
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
 -h, --help                    display this usage message and exit
 --no-checksums                don't verify files with checksums
 --checksums-only              just compare directories with checksums
 --include-hidden              include hidden files (those starting with a '.')
 --auto-folder-naming [prefix] automatically create a new folder for offload
                               (prefix example: "/Day-003-\$(date +'%Y-%m-%d')/Offload-")
EOF

	exit 1
}

VERIFY_FILES=1
VERIFY_ONLY=0
INCLUDE_HIDDEN=0
AUTO_FOLDER_NAMING=0

auto_folder_naming_prefix=""

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
    --auto-folder-naming)
        AUTO_FOLDER_NAMING=1
        auto_folder_naming_prefix="$2"
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

if [ ! -d "$source" ] ; then
	echo "Source is not a directory: $source"
	usage
fi

if [ ${#copies[@]} -lt 1 ] ; then
	echo "Must specify source and destination directories"
	usage
fi

info "$source" $copies $INCLUDE_HIDDEN $VERIFY_FILES $VERIFY_ONLY $AUTO_FOLDER_NAMING

#trap "trap - SIGTERM && kill 0" SIGINT SIGTERM EXIT

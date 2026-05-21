#!/bin/bash
#
# Script to generate Master Boot Record (MBR) test files
# Requires Mac OS

EXIT_SUCCESS=0
EXIT_FAILURE=1

# Checks the availability of a binary and exits if not available.
#
# Arguments:
#   a string containing the name of the binary
#
assert_availability_binary()
{
	local BINARY=$1

	which ${BINARY} > /dev/null 2>&1
	if test $? -ne ${EXIT_SUCCESS}
	then
		echo "Missing binary: ${BINARY}"
		echo ""

		exit ${EXIT_FAILURE}
	fi
}

assert_availability_binary hdiutil
assert_availability_binary sw_vers

MACOS_VERSION=`sw_vers -productVersion`
SHORT_VERSION=`echo "${MACOS_VERSION}" | sed 's/^\([0-9][0-9]*[.][0-9][0-9]*\).*$/\1/'`
MAJOR_VERSION=`echo "${MACOS_VERSION}" | sed 's/^\([0-9][0-9]*\).*$/\1/'`

# Note that versions of Mac OS before 10.13 do not support "sort -V"
MAXIMUM_VERSION=`echo "${MAJOR_VERSION} 10" | tr ' ' '\n' | sed 's/[.]//' | sort -rn | head -n 1`

if test "${MAXIMUM_VERSION}" == "10"
then
	MINIMUM_VERSION=`echo "${SHORT_VERSION} 10.13" | tr ' ' '\n' | sed 's/[.]//' | sort -n | head -n 1`

	if test "${MINIMUM_VERSION}" != "1013"
	then
		echo "Unsupported MacOS version: ${MACOS_VERSION}"

		exit ${EXIT_FAILURE}
	fi
fi

SPECIMENS_PATH="specimens/${MACOS_VERSION}"

if test -d ${SPECIMENS_PATH}
then
	echo "Specimens directory: ${SPECIMENS_PATH} already exists."

	exit ${EXIT_FAILURE}
fi

mkdir -p ${SPECIMENS_PATH}

set -e

echo "Creating: MBR; with file system: HFS+"
hdiutil create -fs 'HFS+' -layout 'MBRSPUD' -size "4M" -type UDIF "${SPECIMENS_PATH}/mbr"

exit ${EXIT_SUCCESS}

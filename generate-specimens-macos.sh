#!/bin/bash
#
# Script to generate Master Boot Record (MBR) test files
# Requires macOS

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

MACOS_VERSION=`sw_vers -productVersion`;

MINIMUM_VERSION=`echo "${MACOS_VERSION} 10.13" | tr ' ' '\n' | sort -V | head -n 1`;

if test "${MINIMUM_VERSION}" != "10.13";
then
	echo "Unsupported MacOS version: ${MACOS_VERSION}";

	exit ${EXIT_FAILURE};
fi

SPECIMENS_PATH="specimens/${MACOS_VERSION}";

if test -d ${SPECIMENS_PATH};
then
	echo "Specimens directory: ${SPECIMENS_PATH} already exists.";

	exit ${EXIT_FAILURE};
fi

mkdir -p ${SPECIMENS_PATH};

set -e;

DEVICE_NUMBER=`diskutil list | grep -e '^/dev/disk' | tail -n 1 | sed 's?^/dev/disk??;s? .*$??'`;

VOLUME_DEVICE_NUMBER=$(( ${DEVICE_NUMBER} + 1 ));

# Create raw disk image with a MBR volume system
IMAGE_NAME="mbr";
IMAGE_SIZE="4M";

hdiutil create -fs 'HFS+' -layout 'MBRSPUD' -size ${IMAGE_SIZE} -type UDIF ${SPECIMENS_PATH}/${IMAGE_NAME};

exit ${EXIT_SUCCESS};


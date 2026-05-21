#!/bin/bash
#
# Script to generate Master Boot Record (MBR) test files
# Requires Linux with dd and fdisk

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

assert_availability_binary dd
assert_availability_binary fdisk

set -e

SPECIMENS_PATH="specimens/fdisk"

mkdir -p ${SPECIMENS_PATH}

IMAGE_SIZE=$(( 4096 * 1024 ))

for SECTOR_SIZE in 512 1024 2048 4096
do
	IMAGE_FILE="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_single_primary.raw"

	echo "Creating: MBR; with single partition; with sector size: ${SECTOR_SIZE}"
	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_FILE} <<EOT
n
p
1

+64K
w
EOT

	IMAGE_FILE="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_multi_primary.raw"

	echo "Creating: MBR; with multiple partitions; with sector size: ${SECTOR_SIZE}"
	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_FILE} <<EOT
n
p
1

+64K
n
p
2

+64K
n
p
3

+64K
n
p

+64K
w
EOT

	IMAGE_FILE="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_extended_no_logical.raw"

	echo "Creating: MBR; with an extended partition without logical parititions; with sector size: ${SECTOR_SIZE}"
	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_FILE} <<EOT
n
e
1


w
EOT

	IMAGE_FILE="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_extended_single_logical.raw"

	echo "Creating: MBR; with an extended partition with a single logical paritition; with sector size: ${SECTOR_SIZE}"
	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_FILE} <<EOT
n
e
1


n

+64K
w
EOT

	IMAGE_FILE="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_extended_multi_logical.raw"

	echo "Creating: MBR; with an extended partition with multiple logical parititions; with sector size: ${SECTOR_SIZE}"
	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_FILE} <<EOT
n
e
1


n

+64K
n

+64K
n

+64K
n

+64K
w
EOT

	IMAGE_FILE="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_multi_primary_extended_multi_logical.raw"

	echo "Creating: MBR; with multiple primary, an extended partition and logical partitions; with sector size: ${SECTOR_SIZE}"
	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_FILE} <<EOT
n
p
1

+64K
n
p
2

+64K
n
p
3

+64K
n
e


n

+64K
n

+64K
n

+64K
n

+64K
w
EOT

	# A MBR with out-of-order partitions, is an MBR where the extended and logical
	# partitions come before the primary partitions.
	IMAGE_FILE="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_out_of_order.raw"

	echo "Creating: MBR; with out-of-order partitions; with sector size: ${SECTOR_SIZE}"
	dd if=/dev/zero of=${IMAGE_FILE} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_FILE} <<EOT
n
e
1

+2048K
n
p
2

+64K
n
p
3

+64K
n
p


n

+64K
n

+64K
n

+64K
n

+64K
w
EOT

done

exit ${EXIT_SUCCESS}

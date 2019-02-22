#!/bin/bash
#
# Script to generate Master Boot Record (MBR) test files
# Requires Linux with dd and fdisk

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

# Checks the availability of a binary and exits if not available.
#
# Arguments:
#   a string containing the name of the binary
#
assert_availability_binary()
{
	local BINARY=$1;

	which ${BINARY} > /dev/null 2>&1;
	if test $? -ne ${EXIT_SUCCESS};
	then
		echo "Missing binary: ${BINARY}";
		echo "";

		exit ${EXIT_FAILURE};
	fi
}

assert_availability_binary dd;
assert_availability_binary fdisk;

set -e;

SPECIMENS_PATH="specimens/linux-fdisk";

mkdir -p ${SPECIMENS_PATH};

IMAGE_SIZE=$(( 4096 * 1024 ));

for SECTOR_SIZE in 512 1024 2048 4096;
do
	# Create a MBR with a single primary partition
	IMAGE_NAME="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_single_primary.raw"

	dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_NAME} <<EOT
n
p
1

+64K
w
EOT

	# Create a MBR with multiple primary partitions
	IMAGE_NAME="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_multi_primary.raw"

	dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_NAME} <<EOT
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

	# Create a MBR with an extended partition without logical parititions
	IMAGE_NAME="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_extended_no_logical.raw"

	dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_NAME} <<EOT
n
e
1


w
EOT

	# Create a MBR with an extended partition with a single logical paritition
	IMAGE_NAME="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_extended_single_logical.raw"

	dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_NAME} <<EOT
n
e
1


n

+64K
w
EOT

	# Create a MBR with an extended partition with multiple logical parititions
	IMAGE_NAME="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_extended_multi_logical.raw"

	dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_NAME} <<EOT
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

	# Create a MBR with multiple primary, an extended partition and logical partitions
	IMAGE_NAME="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_multi_primary_extended_multi_logical.raw"

	dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_NAME} <<EOT
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

	# Create a MBR with out-of-order partitions, where the extended and logical partitions
	# come before the primary partitions.
	IMAGE_NAME="${SPECIMENS_PATH}/mbr_${SECTOR_SIZE}_out_of_order.raw"

	dd if=/dev/zero of=${IMAGE_NAME} bs=${SECTOR_SIZE} count=$(( ${IMAGE_SIZE} / ${SECTOR_SIZE} ))

	fdisk -b ${SECTOR_SIZE} -u ${IMAGE_NAME} <<EOT
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

exit ${EXIT_SUCCESS};


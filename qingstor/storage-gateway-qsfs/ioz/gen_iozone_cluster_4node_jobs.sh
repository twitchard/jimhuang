#! /bin/bash
#
# generate nfs server cluster iozone jobs
SCRIPTS="run_nfs_cluster_4node_ioz_jobs.sh"
IOZONE="iozone"
NODES="4"
CLUSTER_FILE="cluster_4node.conf"
OUTPUT_FILE="qs_nas-gw_cluster_4node_rw_iozone.log"
RECORDS1="4 8 16 32"
RECORDS2="64 128 256 512 1024 2048 4096 8192 16384"
FILESIZES1="64 128 256 512 1024 2048 4096 8192 16384"
FILESIZES2="32768 65536 131072 262144 524288"
FILESIZES="${FILESIZES1} ${FILESIZES2}"

echo "# run iozone nfs cluster jobs" > $SCRIPTS
for RECORD in `eval echo $RECORDS1`; do
	for FILESIZE in `eval echo $FILESIZES1`; do
		echo "$IOZONE -ceC -i 0 -i 1 -r $RECORD -s $FILESIZE -t $NODES -+m $CLUSTER_FILE >> $OUTPUT_FILE" >> $SCRIPTS  
	done
done

for RECORD in `eval echo $RECORDS2`; do
	for FILESIZE in `eval echo $FILESIZES`; do
		if [ $RECORD -le $FILESIZE ]; then
			echo "$IOZONE -ceC -i 0 -i 1 -r $RECORD -s $FILESIZE -t $NODES -+m $CLUSTER_FILE >> $OUTPUT_FILE" >> $SCRIPTS  
		fi
	done
done


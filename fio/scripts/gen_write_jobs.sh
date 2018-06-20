#!/bin/bash
#
# generate write jobs
USERS="01 02 04 08"
BLOCKSIZES_IN_K="0004 0016 0064 0256"
BLOCKSIZES_IN_M="01 04 16"

for USER in `eval echo $USERS`; do
  FIO_RUN="run_fio_write_u${USER}.sh"
  echo "# run all write jobs" > ${FIO_RUN}
  for BSIZE in `eval echo $BLOCKSIZES_IN_K`; do
    jobname="write_u${USER}_bs${BSIZE}k_s128m"
    jobfile="${jobname}.job"
    # generate job file
    echo "[${jobname}]" > $jobfile
    echo "include write.fio" >> $jobfile
    echo "filename=${jobname}.fio" >> $jobfile
    echo "bs=${BSIZE}k" >> $jobfile
    echo "size=128MB" >> $jobfile
    echo "numjobs=${USER}" >> $jobfile
    echo "write_bw_log=${jobname}" >> $jobfile
    echo "write_iops_log=${jobname}" >> $jobfile
    # add entry to FIO_RUN
    echo "fio --output ${jobname}.log ${jobfile}" >> ${FIO_RUN}
  done
  #
  for BSIZE in `eval echo $BLOCKSIZES_IN_M`; do
    jobname="write_u${USER}_bs${BSIZE}m_s512m"
    jobfile="${jobname}.job"
    # generate job file
    echo "[${jobname}]" > $jobfile
    echo "include write.fio" >> $jobfile
    echo "bs=${BSIZE}m" >> $jobfile
    echo "filename=${jobname}.fio" >> $jobfile
    echo "size=512MB" >> $jobfile
    echo "numjobs=${USER}" >> $jobfile
    echo "write_bw_log=${jobname}" >> $jobfile
    echo "write_iops_log=${jobname}" >> $jobfile
    # add entry to FIO_RUN
    echo "fio --output ${jobname}.log ${jobfile}" >> ${FIO_RUN}
  done
done


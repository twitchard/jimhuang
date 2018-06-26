# set up

## add hosts and visit console to create bucket

1. add hosts
139.198.127.164 console.w.yunify.com portal.w.yunify.com stor.qingstor.com gd2b.stor.yunify.com

2. visit console and create bucket

console.w.yunify.com # user: jim@w.yunify.com  passwd:小写
create bucket
create api keys

## setup nfs/qsfs on gdb2 env

1. ssh -p 6023 root@139.198.127.164  # log on first box
2. ssh gateway0 # log on gateway0
3. ssh gateway1 # log on gateway1
4. look up gateway0/1 ip address
  - check `/etc/hosts` or 
  - `ip addr` check bond0

It seems rpcbind service is not normal on gateway0, so setup nfs service on gateway1 and nfs client on gateway0.

```sh
ssh gateway1
yum install nfs-utils
rpm -i qsfs # intall qsfs rpm
qsfs qs-sg-qsfs-test /mnt/qsfs -c=/etc/qsfs_gdb2.cred -z=gd2b -Z=2000 -H=stor.yunify.com -p=http -oallow_other -obig_writes -omax_write=1048576 -omax_readahead=1048576 -f -d -L=info -U -J
vi /etc/exports # add /mnt/qsfs *(fsid=0,rw,no_root_squash,sync)
systemctl start rpcbind.service
systemctl start nfs.service
exportfs -rv
showmount -e
ssh gateway0
mount -t nfs -o vers=3,nolock <gateway1 ip>:/mnt/qsfs/ /mnt/nas
mount -t nfs -o vers=3,nolock,bg,hard,intr,rsize=131072,wsize=131072 10.16.141.11:/mnt/storage-gateway /mnt/nas
```

> Notes: use -Z to enlarge max cache size
> This will helpful fo NFS cluster test.

[Linux NFS-Howto][NFS-howto]

## install iozone

```sh
wget http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
rpm -Uvh rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
yum install iozone
```
[iozone centos7 install howto][iozone_centos_7_install_howto]

## install fio

```sh
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/libaio-devel-0.3.109-13.el7.x86_64.rpm
rpm -i libaio-devel # must install devel to enable libaio
git clone https://github.com/axboe/fio.git
cd fio
./configure
make && make install
```


## iozone nfs-client performance

- Standard setups for NFS client
```sh
iozone -Race -i 0 -i 1 -+n -U /mnt/nas-gw -f /mnt/nas-gw/nas-gw_client_test.ioz -b ./qs_nas-gw_client_rw_iozone.xls > qs_nas-gw_client_rw_iozone.log
```
`-R` Generate Excel report

`-b` Iozone will create a binary file format file in Excel compatible output of results

`-a` used to select full automatic mode. Produces output that covers all testd file operations for record sizes of 4k to 16M for file size of 64k to 512M

`-c` include close() int the timing calculations.

`-e` include flush (fsync, fflush) in the timing calculations

`-f` Used to specify the filename for the temporary file under test. This is useful when the unmount optoin is used. When testing with unmount between tests it is necessary for he temporary file under test to be in a directory that can be umounted.

`-U` Mount point ot unmount and remount between tests. Iozone will umount and remount this mount point before beginning each test. This guarantees that the buffer cache does not contain any of he file under test.

- `/etc/fstab` add entry for nfs, this will enable iozone perform unmount and remount actions.
```sh
10.16.141.11:/mnt/storage-gateway           /mnt/nas-gw           nfs     rw,vers=3,nolock,bg,hard,intr,rsize=131072,wsize=131072 0 0
```

## iozone nfs server cluster mode performance 

- install iozone on both nfs server and clients
- run iozone on nfs-server side
- replace rsh with ssh

```sh
export RSH=ssh;export rsh=ssh
```

- config ssh screct key logon

- NFS clients configure file

```sh
# server ip  client mountpoint  iozone exe path
10.16.141.21 /mnt/nas-gw /usr/bin/iozone
10.16.141.22 /mnt/nas-gw /usr/bin/iozone
```

- run iozone command 

```sh
iozone -ceC -i 0 -i 1 -r 4 -s 64 -t 2 -+m cluster_2node.conf
```
`-C` Show bytes transferred by each child in throughput testing.

`-t` Run Iozone in a throughtput mode. This option allows the user to specify how many threads or processes to have active during the measurement

`-+m` Use this file to obtain the configuration information of the clients for cluster testing.

> Notes
> option `-w` can be used to "Do not unlink temporary files when finished using them. Leave them present in the filesystem"
> 
> As iozone thoughput mode for cluster testing is not able to support Unmount/Mount nfs clients, so when use `-w` option, cluster performance test shows there is extrordinary write performance (nearly 180 MBytes/s) for cluster, this maybe not reasonable, as qsfs(storage-gateway) probably cache the testfile, so following test io just hit the memory cache, so do not use `-w` to make the test file unlinked when finished test this will invoke qsfs to delete the testfile from cache.


### scripts to generate nfs cluster iozone jobs

```bash
#! /bin/bash
#
# generate nfs server cluster iozone jobs
SCRIPTS="run_nfs_cluster_2node_ioz_jobs.sh"
IOZONE="iozone"
NODES="2"
CLUSTER_FILE="cluster_2node.conf"
OUTPUT_FILE="qs_nas-gw_cluster_2node_rw_iozone.log"
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
```

### generate table for iozone nfs cluster throughtput test

```sh
egrep "Command line|writers|readers" cluster_2node.log | sed 's/^.*=//' | sed 's/^.* -r //' | awk '{print $3 " " $1}' | paste -d ' ' - - - - -
```

> egrep "Command line|writers|readers"　# 提取行

> sed 's/^.*=//'　　# 将行首至 `=` 处替换为空

> sed 's/^.* -r //' # 将行首至 ` -r ` 替换为空

> awk '{print $3 " " $1}'  # 将以空格分隔的第三列和第一列依次输出

> paste -d ' ' - - - - - # 将每五行合并为一行

exmaple

input after egrep:
>      Command line used: iozone -ceC -i 0 -i 1 -r 4 -s 64 -t 2 -+m cluster_2node.conf
>      Children see throughput for  2 initial writers  =     100.46 kB/sec
>      Children see throughput for  2 rewriters        =   21607.32 kB/sec
>      Children see throughput for  2 readers          =    3385.13 kB/sec
>      Children see throughput for 2 re-readers        = 2948642.25 kB/sec
>      Command line used: iozone -ceC -i 0 -i 1 -r 4 -s 128 -t 2 -+m cluster_2node.conf
>      Children see throughput for  2 initial writers  =     225.77 kB/sec
>      Children see throughput for  2 rewriters        =   38735.28 kB/sec
>      Children see throughput for  2 readers          =    5623.13 kB/sec
>      Children see throughput for 2 re-readers        = 3945362.25 kB/sec
>      Command line used: iozone -ceC -i 0 -i 1 -r 4 -s 256 -t 2 -+m cluster_2node.conf
>      Children see throughput for  2 initial writers  =     173.87 kB/sec
>      Children see throughput for  2 rewriters        =   77870.62 kB/sec
>      Children see throughput for  2 readers          =    6099.41 kB/sec
>      Children see throughput for 2 re-readers        = 4924948.50 kB/sec

output:

>     64 4  100.46  21607.32  3385.13  2948642.25
>     128 4  225.77  38735.28  5623.13  3945362.25
>     256 4  173.87  77870.62  6099.41  4924948.50

[Analyzing NFS Client Performance with IOzone][Analyzing_nfs_client_performance_with_iozone]
[Linux NFS-Howto][NFS-howto]
[IOzone documentation][iozone_doc]

[iozone_centos_7_install_howto]:https://centos.pkgs.org/7/repoforge-x86_64/iozone-3.424-1.el7.rf.x86_64.rpm.html
[iozone_doc]:http://www.iozone.org/docs/IOzone_msword_98.pdf
[Analyzing_nfs_client_performance_with_iozone]:http://www.iozone.org/docs/NFSClientPerf_revised.pd
[NFS-howto]:http://nfs.sourceforge.net/nfs-howto/index.htm


## iozone output gnuplot

- How to uses, check /current/Genplot.txt
```sh
Generate_Graphs iozone.out
```
> Hit return to continue gnuplot to plot next izone test type (write, rewrite, read, reread ...)
> Also postscript file are generated in the test sub-directory, you can use app such as `evince` to open it

- To customize the plot, make some changes in `gnu3d.dem`

- 你可以参考`izone -a`的输出结果，第一张表格，制作相应数据表格，要求列抬头和列的顺序是一直即可，行的顺序没有要求．制作的表格可以作为输入来生成图表．通过这种方法可以制作 nfs cluster throughtput performace test 的图．


[iozone gnuplot]:[iozone_gnuplot]

## NOTES
fio 测试一定要对应不同测试给不同文件名，避免错误，文件size一定要是bs的整数倍

[iozone_gnuplot]:https://github.com/jimhuaang/iozone/tree/master/src/current


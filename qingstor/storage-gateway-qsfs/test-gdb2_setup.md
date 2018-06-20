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
qsfs qs-sg-qsfs-test /mnt/qsfs -c=/etc/qsfs_gdb2.cred -z=gd2b -H=stor.yunify.com -p=http -oallow_other -obig_writes -omax_write=1048576 -omax_readahead=1048576 -f -d -L=info -U
vi /etc/exports # add /mnt/qsfs *(fsid=0,rw,no_root_squash,sync)
systemctl start rpcbind.service
systemctl start nfs.service
exportfs -rv
showmount -e
ssh gateway0
mount -t nfs -o vers=3,nolock <gateway1 ip>:/mnt/qsfs/ /mnt/nas
mount -t nfs -o vers=3,nolock -o bg,soft,rsize=32768,wsize=32768 gd2br03n01:/mnt/storage-gateway /mnt/nas

```


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


[iozone_centos_7_install_howto]:https://centos.pkgs.org/7/repoforge-x86_64/iozone-3.424-1.el7.rf.x86_64.rpm.html


## NOTES
fio 测试一定要对应不同测试给不同文件名，避免错误，文件size一定要是bs的整数倍
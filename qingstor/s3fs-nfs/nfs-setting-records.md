# s3fs - nfs

## nfs server

- os: CentOS 7.2 x86_64

- packages: nfs-utils

```sh
yum install nfs-utils
```

- s3fs

```sh
# install
yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel
./autogen.sh
./configure
make && sudo make install
#mount
nohup s3fs <BUCKET> <MOUNT> -o url=http://s3.pek3a.qingstor.com -d -d -f
#fstab
s3fs#mybucket /mnt/mybucket fuse _netdev,url=http://s3.pek3a.qingstor.com,allow_other 0 0
```

- /etc/exports

/mnt/goofys *(fsid=0,rw,no_root_squash)
/mnt/s3fs *(fsid=0,rw,no_root_squash,sync)

- nfs service start/stop/status

systemctl start rpcbind.service
systemctl start nfs.service
exportfs -r
netstat -anutlp | grep 2049
> notes: start rpc service at first
> mount s3fs before start nfs service

## nfs client

showmount -e ip
> ip should be LAN ip address

nfsstat -m

mount -t nfs -o proto=tcp,nolock nfs-serverip:/export/dir /mount/dir

## 部署到 qs

默认登录ks0:
ssh user@ip

从ks0 登录到 first-box, 两种方式

- ssh -p 6023 firstbox
- docker exec -it firstbox bash  进入firstbox

拷贝rpms到 /var/www/repo/rmps
yum clean all
yum makecache

firstbox 登录到ks0, 或者ks0, ks1直接相互登录
ssh ks0
ssh ks1

qsfs -p=http -H=stor.dlrcb.cn -z=dalia

1. 先停掉nfs：　systemctl stop nfs.servie
2. 卸载qsfs: umount -l /mnt/qingstor
3. 重新指定参数挂载qsfs, 命令如下： -y 指定大小,　以G为单位，比如10G,如下
qsfs haikang /mnt/qingstor -y=10 -F=666 -D=777 -p=http -z=dalian -H=stor.dlrcb.cn -c=/etc/qingstor/credentials -o allow_other -d -L=info -l=/qingstor/log/qsfs
4. 重新开启nfs服务：　systemctl start nfs.service
5. exportfs -rv
6. 确认export了 /mnt/qingstor
   showmount -e
7. 清除　/mnt/qingstor 目录内容
　　cd /mnt/qingstor
   rm -rf ./*

日志：　/qingstor/log/qsfs
/qingstor/log/s3fs
qsfs haikang /mnt/qingstor -y=5120 -F=666 -D=777 -p=http -z=dalian -H=stor.dlrcb.cn -c=/etc/qingstor/credentials -o allow_other -d -L=info -l=/qingstor/log/qsfs

ssh ks1

mount命令：
linux:
mount -t nfs -o vers=3,nolock 10.8.166.146:/mnt/qingstor/ /mnt/nas/

mac:
不可以用 -o vers=3,nolock; 需要加 -o resvport


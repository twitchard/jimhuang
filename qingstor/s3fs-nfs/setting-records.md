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

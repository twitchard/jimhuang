# ganesha-nfs

## Trouble shooting

1. Error binding to V6 interface. Cannot continue.

原因可能包括: 

- 开启了 nfsd 服务，默认若安装了 nfs-server, ubuntu 默认都会开启 nfsd,使用以下命令停止服务：

```bash
service nfs-kernel-server stop
```

- 可能未开启 rpcbind

```bash
systemctl start rpcbind.service
```
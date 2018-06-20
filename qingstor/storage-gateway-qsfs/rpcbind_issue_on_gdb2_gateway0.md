## It seems rpcbind service is not working on gateway0

1. 安装nfs后，开启服务
yum install nfs-utils
systemctl start rpcbind.service
systemctl start nfs.service
exportfs -rv

2. showmont -e 报错
root@gd2br03n00:/mnt# showmount -e
clnt_create: RPC: Program not registered

3. 检查 rpcbind 服务，有告警提示
root@gd2br03n00:/mnt# systemctl status rpcbind.service
● rpcbind.service - RPC bind service
   Loaded: loaded (/usr/lib/systemd/system/rpcbind.service; indirect; vendor preset: enabled)
   Active: active (running) since Mon 2018-06-18 10:34:25 CST; 10min ago
 Main PID: 3752 (rpcbind)
   Memory: 652.0K
   CGroup: /system.slice/rpcbind.service
           └─3752 /sbin/rpcbind -w

Jun 18 10:34:25 gd2br03n00 systemd[1]: Starting RPC bind service...
Jun 18 10:34:25 gd2br03n00 rpcbind[3751]: cannot bind * on udp: Address already in use　< warning
Jun 18 10:34:25 gd2br03n00 rpcbind[3751]: cannot bind tcp: Address already in use       < warning
Jun 18 10:34:25 gd2br03n00 systemd[1]: Started RPC bind service.
Jun 18 10:39:01 gd2br03n00 systemd[1]: Started RPC bind service.

4. 重装 nfs, 重启服务后，问题依然存在
systemctl stop nfs.service
systemctl stop rpcbind.service
systemctl start rpcbind.service
systemctl start nfs.service

5. rpcinfo -p 显示告警
root@gd2br03n00:/mnt# rpcinfo -p
No remote programs registered.

6. rpcinfo | grep 111 没有输出
root@gd2br03n00:/mnt# rpcinfo | grep 111

基于以上信息，判定 gateway0上 rpcbind 服务不正常

在 gateway1 上 rpcbind 正常，输出信息如下
root@gd2br03n01:~# rpcinfo | grep 111
    100000    4    tcp6      ::.0.111               portmapper superuser
    100000    3    tcp6      ::.0.111               portmapper superuser
    100000    4    udp6      ::.0.111               portmapper superuser
    100000    3    udp6      ::.0.111               portmapper superuser
    100000    4    tcp       0.0.0.0.0.111          portmapper superuser
    100000    3    tcp       0.0.0.0.0.111          portmapper superuser
    100000    2    tcp       0.0.0.0.0.111          portmapper superuser
    100000    4    udp       0.0.0.0.0.111          portmapper superuser
    100000    3    udp       0.0.0.0.0.111          portmapper superuser
    100000    2    udp       0.0.0.0.0.111          portmapper superuser


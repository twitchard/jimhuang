# To test qfs-meta, qfs-fuse, qfs-master locally

## setup


### qfs-fuse

- 1. need to update go version to 1.9 or later, refer [update-golang][update-go-version]

- 2. download repo from gitlab, put it under workspace, no need to put it under $GOPATH/src, because all repo/deps are handled in Makefile

- 3. when make, there is some access permission problem due to clone use git protocol, resolve it by hand with git clone https (qs-common-go, mysqlmgr..)

### qfs-meta

- 4. before make qfs-meta, need to handle submodule at first (`git submodule init && git submodule update`)

- 5. troubleshooting, qfs-meta submodule issue, when you invoke make before init/update submodule, you will meet following fatal message:

    ```
    fatal: no submodule mapping found in .gitmodules for path 'src/github.com/stretchr/testify
    ```

    your need to use `git rm` to remove the special entry which not existing in .gitsubmodules, refer [resolve no submodule mapping][resolve_no_submodule_mapping]

- 6. [install docker-ce][install_docker_ubuntu16] and start docker (`systemctl start docker`)

- 7. [install docker compose][install_docker_compose]

- 8. install mysql-client-core
 
   ```
    apt-cache search mysql-client
    sudo apt-get update && sudo apt-get install mysql-client-core-5.7
   ```

- 8. qfs-meta need co branch meta to do test: `git checkout -b meta origin/meta`

- 9. `bash scripts/test_setup.sh && sudo make test-start`


### qfs-io

- 10. `make` will have following warnings:
    ```
    build/src/qfs_io/lib/tx_rpc.go:11: running "msgp": exec: "msgp": executable file not found in $PATH
    ```
   Because `msgp` executable file has been put at qfs-io/ root dir, so append the qfs-io/ root dir to PATH.

- 11. `make test-start` will have following warnings:
```
dd: failed to open '/qingstor/data/loopback.img': No such file or directory
```
Need to create directory of `/qingstor/data` at first

```
losetup: /qingstor/data/loopback.img: failed to set up loop device: Device or resource busy
jim@jjimhuang:~/workspaces/qfs-io$ losetup
NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE
/dev/loop1         0      0         1  1 /var/lib/snapd/snaps/core_4571.snap
/dev/loop0         0      0         1  1 /var/lib/snapd/snaps/core_4650.snap
/dev/loop3         0      0         1  1 /var/lib/snapd/snaps/core_4830.snap
```

/dev/loop1 is occupied by snap.
so change qfs-io/qfs-fuse/qfs-master dev to /dev/loop4

### qfs-master

12. commit vendor.json, change lz4 entry as same as qfs-io.

gateway0
cd ~/gopath/src/qfs-master/conf/goreman_conf
goreman start


[update-go-version]:https://github.com/udhos/update-golang
[resolve_no_submodule_mapping]:https://stackoverflow.com/questions/4185365/no-submodule-mapping-found-in-gitmodule-for-a-path-thats-not-a-submodule
[install_docker_ubuntu16]:https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
[install_docker_compose]:https://docs.docker.com/compose/install/



### debug qfs-fuse, qfs-io
see dir debug/vscode for vscode config

1. mount loop device: cd qfs-io; make test-start

2. qfs-tool -d /dev/loop4 mkfs

3. ./build/qfs_meta -conf conf/qfs_meta.yaml

4. ./build/qfs_fuse -conf conf/qfs_fuse.yaml

5. start ganesha.nfsd

6. mount exported dir


### test fsal_qfs

1. service nfs-kernel-service stop

2. setup loop device
   qfs_io/make test-start
   qfs_tools -d /dev/loop4 mkfs

3. launch docker/db
   qfs_meta/make test-start

   when meet mysql timeout error, try 'bash script/test_setup.sh' manually, if still not work, try to stop/start docker container 'qfs_meta_galera_meta-0_1'
```
        docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                    NAMES
cb149828bbc7        galera_meta         "/bin/sh -c 'bash /q…"   4 days ago          Up About a minute   4444/tcp, 4567-4568/tcp, 127.0.0.1:3706->3306/tcp        qfs_meta_galera_meta-0_1

docker stop cb149828bbc7
docker start cb149828bbc
docker exec -it cb149828bbc bash
```

4. launch qfs-meta
    ./build/qfs-meta conf ./conf/qfs_meta.yaml

5. Setup env using qfs_fuse
   ./build/qfs-fuse conf ./conf/qfs_fuse.yaml
   cd mount_point && mkdir jim  # the root dir of export

6. conf ganesh.conf
  path = /jim
  Pseduo = /

7. mount -t nfs localhost:/ /qingstor/mnt

8. cleanup meta db
   bash  script/test_cleandb.sh
   bash script/test_setup.sh

9. mysql 
docker ps
mysql -u yunify -P 3706 -p -h 127.0.0.1
show databases
use <DATABASE>
show tables
select * from qfs_meta_2.inode_parent;

10. remove image 'galera_meta' (restart docker) 
docker stop qfs_meta_galera_meta-0_1
docker rm qfs_meta_galera_meta-0_1
docker images
docker rmi galera_meta

qfs-meta: make test-start

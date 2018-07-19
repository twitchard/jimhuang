
1. 启动各组件

  登录 gateway0
  cd /root/gopath
  cd qfs-meta (fuse/master)
  make
  meta fuse, agent 都是./build/qfs_[meta/fuse] -conf conf/qfs_[meta/fuse].yaml

  master 
  cd conf/goreman_conf/
  goreman start

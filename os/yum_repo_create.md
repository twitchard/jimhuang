# 私有云环搭建 local repo

可参考文档　
- [How to setup your own package repository][yum_setup_own_repo]
- [Centos7 本地源搭建][centos7_local_repocreate]

## 示例一　部署 qsfs

基本过程是先在有网络的环境准备好所有的包文件，拷贝到部署机器，在部署机器上创建设置yum源库

### 1. yum install package＿list --downloadonly --downloaddir=/path/to/dir

- qsfs包以及依赖
- createrepo 以及依赖，用于创建yum源索引
- yum-plugin-priorities以及依赖，　用于设置yum源优先级

```sh
yum install gcc gcc-c++ git fuse fuse-devel libcurl-devel openssl-devel createrepo yum-plugin-priorities --downloadonly --downloaddir=/my_dir
```

### 2. 拷贝所有 packags 到部署机器

拷贝　packages 到　/mnt/local_yum　目录

### 3. 部署机器上手动安装 createrepo

```sh
  rpm -ihv deltarpm-3.6-3.el7.x86_64.rpm 
  rpm -ihv --nodeps libxml2-python-2.9.1-6.el7_2.3.x86_64.rpm (避免libxml2的冲突，加--nodeps选项)
  rpm -ihv python-deltarpm-3.6-3.el7.x86_64.rpm 
  rpm -ihv createrepo-0.9.9-28.el7.noarch.rpm 
```

### 4. 创建 yum repo

- yum repo 路径默认在 /etc/yum.repos.d/ 中，　vi /etc/yum.repos.d/local.repo, 输入以下内容


```sh
[local]
name=CentOS-$releasever - Local
baseurl=file:///mnt/local_yum/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rmp-gpg/RMP-GPG-KEY-CentOS-7
priority=1
```

- 创建 repo 描述文件

```sh
cd /mnt/local_yum
createrepo ./
```

- 刷新 yum 缓存

```sh
yum clean all
yum makecache
```

### 5. 验证

```sh
yum install yum-plugin-priorities
yum install gcc gcc-c++ git fuse fuse-devel libcurl-devel openssl-devel createrepo yum-plugin-priorities
rpm -ivh /mnt/local_yum/qsfs.rpm
```

### 6. 修改原有 repo 的优先级 (可选)

优先级数字越小，优先级越高
在 /etc/yum.repos.d/CentOS-Base.repo 中添加　priority=2

[yum_setup_own_repo]: http://yum.baseurl.org/wiki/RepoCreate
[centos7_local_repocreate]: https://blog.csdn.net/gcangle/article/details/50197753
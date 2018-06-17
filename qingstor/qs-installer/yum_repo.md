# qs-installer deploy repo rpms

## qs-installer nginx config

/etc/nginx/conf.d/repo.conf

```sh
server {
  listen 80;
  allow 127.0.0.1;
  #
  allow 139.198.XX.XX; # qsfs test, add client IP address
  location / {
    root /var/www/repo
  }
}
```

运行

```sh
nginx -s reload
```

## Copy rpms to qs-installer

copy all rpms to qs-installer following location:
    /var/www/repo/el7/native/rpms  # for native rpms
    /var/www/repo/el7/qsfs/rpms    # for qsfs depeneded rpms

## update repodata and yum cache on qs-installer

```sh
cd /var/www/repo/el7/native/rpms
createrepo .
cd /var/www/repo/el7/qsfs/rpms
createrepo .
yum clean all
yum install
```

## add qs-installer repo to your client 

update /etc/yum.repos.d

```sh
[qs-native]
name=Distribution native packages for QingStor - $basearch 
baseurl=http://119.254.101.59/el7/native/rpms 
failovermethod=priority
enabled=1
gpgcheck=0
```

yum clean all
yum makecache

# Test NFS ganesha

## cthon4

git clone https://github.com/phdeniel/cthon04

- Set cthon04/test.init 

```sh
MNTPOINT="/mnt"
MNTOPTIONS="rw,hard,intr"

FSOPT=nfs

MOUNTCMD='./domount -t $FSOPT -o $MNTOPTIONS $SERVER\:$SERVPATH $MNTPOINT'
UMOUNTCMD='./domount -u $MNTPOINT'

DASHN=-n
BLC=

PATH=/bin:/usr/bin:/usr/ucb:/usr/ccs/bin:/sbin:/usr/sbin:.

SERVER="localhost"
SERVPATH="/upload" # export pseudo path
#SERVPATH="/qingstor/mnt"
TEST="-a"
TESTARG="-t"

CFLAGS=`echo -DLINUX -DHAVE_SOCKLEN_T -DGLIBC=22 -DMMAP -DSTDARG`
LIBS=`echo -lnsl`

MOUNT=/bin/mount
UMOUNT=/bin/umount
LOCKTESTS=`echo tlocklfs tlock64`

CC=gcc
```

- nfs-ganesha config

```sh
EXPORT
{
  Export_Id = 77;

  # Path = /home/jim/share00;
  Path = /qingstor/mnt;

  Pseudo = /upload;

  Access_Type = RW;

  Squash = No_Root_Squash;

  FSAL {
        Name = VFS;
    }
}

CACHEINODE {
  Attr_Expiration_Time = 0;
  Dir_Chunk = 0;
}

NFS_CORE_PARAM {
  mount_path_pseudo = true;
  DRC_Disabled = true;
  Clustered = true;
}
```

- compile cthon04

```sh
cd cthon04
make
```

- run cthon04 test with server script

```sh
./server  ## run all test, read conf from test.init
./server -b  ## run basic test, read conf from test.init
```

see more details about server script options in https://github.com/phdeniel/cthon04
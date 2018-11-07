# backtrace, nm, mmap and addr2line

## ref

- backtrace(3)
- proc(5)
- mmap(2)
- nm(1)
- addr2line(1)

## what backtrace(backtrace_symbols) print ?

```c
  #include <execinfo.h>
  int backtrace(void **buffer, int size);
  char **backtrace_symbols(void *const *buffer, int size);
```

example
```
backtrace() returned 8 addresses
           # function name(hex offset into the function)  [actual return address in hex]
           ./prog(myfunc3+0x5c) [0x80487f0]
           ./prog [0x8048871]
           ./prog(myfunc+0x21) [0x8048894]
           ./prog(myfunc+0x1a) [0x804888d]
           ./prog(myfunc+0x1a) [0x804888d]
           ./prog(main+0x65) [0x80488fb]
           /lib/libc.so.6(__libc_start_main+0xdc) [0xb7e38f9c]
           ./prog [0x8048711]
```

backtrace() returns a backtrace for the calling program, in the array pointed to by `buffer`; `size` specifies the maximum number of addresses that can be stored in `buffer`.

Given the set of addresses returned by backtrace() in buffer,backtrace_symbols() translates the addresses into an array of strings that describe the addresses symbolically.  The size argument specifies the number of addresses in buffer.

<b>The symbolic representation of each address consists of the function name (if this can be determined), a hexadecimal offset into the function, and the actual return address (in hexadecimal).<b>

> notes
    The symbol names may be unavailable without the use of special linker
    options. For systems using the GNU linker, it is necessary to use
    the -rdynamic linker option.  Note that names of "static" functions
    are not exposed, and won't be available in the backtrace.


## How to use nm to find a defined symbols (eg. function) address and size?

`nm` list symbols from object files.

```
$> nm -S /usr/lib/ganesha/libfsalqfs.so | grep ' T '
00000000000055a6 00000000000003b0 T alloc_handle
000000000000d414 0000000000000423 T close2
0000000000008e7f 0000000000000421 T closefile
000000000000c447 00000000000003f6 T commit2
0000000000005956 000000000000027f T dealloc_handle
000000000000e0f0 T _fini
000000000000856f 000000000000026e T getattributes
0000000000002700 T _init
0000000000005bd5 0000000000000042 T is_handle_fini
00000000000087dd 0000000000000167 T linkfile
000000000000c83d 0000000000000030 T lock_op2
000000000000627c 000000000000071f T lookupfile
0000000000006fbe 0000000000000491 T makedir
000000000000744f 0000000000000602 T makenode
0000000000007a51 0000000000000589 T makesymlink
00000000000092a0 0000000000001766 T open2
000000000000dab4 00000000000001e3 T qfs_close_my_fd
00000000000047aa 00000000000006ec T qfs_create_export
000000000000dc97 00000000000002c4 T qfs_find_fd
000000000000541a 000000000000018c T qfs_handle_ops_init
00000000000030ca 000000000000012c T qfs_init
000000000000df5b 0000000000000193 T qfs_inode_attr2stat
```

## what is /proc/$pid/maps?

proc(5)
mmap(2)

mmap()  creates  a  new  mapping in the virtual address space of the calling process.

[A good artical on stackoverflow](https://stackoverflow.com/questions/1401359/understanding-linux-proc-id-maps)

A file containing the currently mapped memory regions and their access permissions. See mmap(2) for some further information about memory mappings.
The format of the file is:

```

address           perms offset  dev   inode       pathname
00400000-00452000 r-xp 00000000 08:02 173521      /usr/bin/dbus-daemon
00651000-00652000 r--p 00051000 08:02 173521      /usr/bin/dbus-daemon
00652000-00655000 rw-p 00052000 08:02 173521      /usr/bin/dbus-daemon
00e03000-00e24000 rw-p 00000000 00:00 0           [heap]
00e24000-011f7000 rw-p 00000000 00:00 0           [heap]
...
35b1800000-35b1820000 r-xp 00000000 08:02 135522  /usr/lib64/ld-2.15.so
35b1a1f000-35b1a20000 r--p 0001f000 08:02 135522  /usr/lib64/ld-2.15.so
35b1a20000-35b1a21000 rw-p 00020000 08:02 135522  /usr/lib64/ld-2.15.so
35b1a21000-35b1a22000 rw-p 00000000 00:00 0
35b1c00000-35b1dac000 r-xp 00000000 08:02 135870  /usr/lib64/libc-2.15.so
35b1dac000-35b1fac000 ---p 001ac000 08:02 135870  /usr/lib64/libc-2.15.so
35b1fac000-35b1fb0000 r--p 001ac000 08:02 135870  /usr/lib64/libc-2.15.so
35b1fb0000-35b1fb2000 rw-p 001b0000 08:02 135870  /usr/lib64/libc-2.15.so
...
f2c6ff8c000-7f2c7078c000 rw-p 00000000 00:00 0    [stack:986]
...
7fffb2c0d000-7fffb2c2e000 rw-p 00000000 00:00 0   [stack]
7fffb2d48000-7fffb2d49000 r-xp 00000000 00:00 0   [vdso]
```

address - This is the starting and ending address of the region in the process's address space

permissions - This describes how pages in the region can be accessed. There are four different permissions: read, write, execute, and shared. If read/write/execute are disabled, a - will appear instead of the r/w/x. If a region is not shared, it is private, so a p will appear instead of an s. If the process attempts to access memory in a way that is not permitted, a segmentation fault is generated. Permissions can be changed using the mprotect system call.

offset - If the region was mapped from a file (using mmap), this is the offset in the file where the mapping begins. If the memory was not mapped from a file, it's just 0.

device - If the region was mapped from a file, this is the major and minor device number (in hex) where the file lives.

inode - If the region was mapped from a file, this is the file number.

pathname - If the region was mapped from a file, this is the name of the file. This field is blank for anonymous mapped regions. There are also special regions with names like [heap], [stack], or [vdso]. [vdso] stands for virtual dynamic shared object. It's used by system calls to switch to kernel mode


## how to use addr2line the locate the filename and line no based on the backtrace output?

add2line convert address to filename and line numbers. Given an address in an executable or an offset in a section of a relocatable object, it uses the debugging information to figure out
which file name and line number are associated with it.


```
nfs-ganesha-4142[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd() [0x440b09]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd() [0x440c07]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :/lib/x86_64-linux-gnu/libpthread.so.0(+0x11390) [0x7ff69284a390]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :/lib/x86_64-linux-gnu/libc.so.6(gsignal+0x38) [0x7ff69205e428]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :/lib/x86_64-linux-gnu/libc.so.6(abort+0x16a) [0x7ff69206002a]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :/lib/x86_64-linux-gnu/libc.so.6(+0x2dbd7) [0x7ff692056bd7]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :/lib/x86_64-linux-gnu/libc.so.6(+0x2dc82) [0x7ff692056c82]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :/usr/lib/ganesha/libfsalqfs.so(lookupfile+0x53f) [0x7ff68f96c7bb]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd(mdc_get_parent+0x8e) [0x547203]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd(mdcache_create_handle+0x175) [0x541750]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd() [0x475013]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd(nfs4_op_putfh+0xd9) [0x475228]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd(nfs4_Compound+0xc06) [0x45cdb3]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd() [0x459a6e]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd(nfs_rpc_valid_NFS+0xa5) [0x45a212]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd() [0x44cd3a]
```

1. for executable `ganesha.nfsd`

For example if we want to see the filename and line number for the following backtrace:

```
nfs-ganesha-4142[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd() [0x440b09]
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :ganesha.nfsd() [0x440c07]
```

```sh
> addr2line -fe /usr/bin/ganesha.nfsd 0x440b09
gsh_backtrace
/root/jim/qfs-ganesha/src/MainNFSD/nfs_init.c:245
> addr2line -fe /usr/bin/ganesha.nfsd 0x440c07
crash_handler
/root/jim/qfs-ganesha/src/MainNFSD/nfs_init.c:263
```

2. for relocatable object `libfsalqfs.so`

For example if we want to see the filename and line number for the following backtrace:

```
nfs-ganesha-4124[svc_11] gsh_backtrace :NFS STARTUP :MAJ :/usr/lib/ganesha/libfsalqfs.so(lookupfile+0x53f) [0x7ff68f96c7bb]
```

At first we need to calculate the address in relocatable object based the offset address in specific function and the absolute address of process 4124.
There are two ways:

1) Use `nm` to locate function address and add up the offset.

```sh
> nm -S /usr/lib/ganesha/libfsalqfs.so | grep ' T ' | grep lookupfile
000000000000627c 000000000000071f T lookupfile
```

The address should be:

0x627c + 0x53f = 0x67bb

2) Search `/proc/4124/maps` for the base address of `libfsalqfs.so` and subtract it from absolute address.


```sh
grep 'libfsal' ./4142/maps  # a copy
7ff68f966000-7ff68f977000 r-xp 00000000 fd:01 677769                     /usr/lib/ganesha/libfsalqfs.so
7ff68f977000-7ff68fb76000 ---p 00011000 fd:01 677769                     /usr/lib/ganesha/libfsalqfs.so
7ff68fb76000-7ff68fb77000 r--p 00010000 fd:01 677769                     /usr/lib/ganesha/libfsalqfs.so
7ff68fb77000-7ff68fb78000 rw-p 00011000 fd:01 677769                     /usr/lib/ganesha/libfsalqfs.so
```

The address should be :

0x7ff68f96c7bb - 0x7ff68f966000 = 0x67bb

The filename and line nubmer is:

```sh
> addr2line -fe /usr/lib/ganesha/libfsalqfs.so 0x67bb
lookupfile
/root/jim/qfs-ganesha/src/FSAL/FSAL_QFS/file.c:160  
```

> notes
  The mmaps file could be removed when process terminated. So you can copy this file when the process is still running.
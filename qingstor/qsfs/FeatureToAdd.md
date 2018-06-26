
- Researching Stackfs

- Researching ToFuseNotToFuse referencing papers (like ReFuse...) 

- fuse init (print qsfs_init to check `fuse_conn_info` while set some mount options like max_read)

check fuse_common.h 'fuse_conn_info' async_read

- Fuse Read-ahead, INIT (refer to paper ToFuseNotToFuse)

- Fuse readdir two implementation (read whole directory in one readdir, or not)

- Interrupt filesystem
  
  Check fusectl (doc/kernel.txt, Stackfs(ToFUSENotToFuse))

  Checkout libfuse github  doc/kenerl.txt
  
  nfs cannot be re-mount when qsfs is not umounted. check doc/kenerl.txt about filesystem connection 

- Tracing fuse-kenerl

  Check Stackfs (ToFuseNotToFuse)

- Fuse Splicing, write_buf (refer to paper ToFuseNotToFuse)

- Support metedata, such as chmod

  s3fs

  convert_header_to_stat

  get_uid

  get_gid
  
- Persistence

  leveldb

  sqlite

- Request queue

  gdfs

  add request pool to filter the http request, do this in ClientImpl level
    
  add file download/upload request pool, do this in TransferManager

- cache memory managing to improve the cache effeciceny, refer circular buffer/ ring buffer.

- read/write in parallel, enable page alignment in order to optimize for perfomance

- Write man page for qsfs






[ToFuseNotToFuse]:
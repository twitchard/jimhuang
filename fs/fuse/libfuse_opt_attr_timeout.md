# Code releated to fuse mount opt attr_timeout

libfuse 3.2.4

```c
//fuse.h
/**
 * Configuration of the high-level API
 *
 * This structure is initialized from the arguments passed to
 * fuse_new(), and then passed to the file system's init() handler
 * which should ensure that the configuration is compatible with the
 * file system implementation.
 */
struct fuse_config {
	/**
	 * If `set_gid` is non-zero, the st_gid attribute of each file
	 * is overwritten with the value of `gid`.
	 */
	int set_gid;
	unsigned int gid;

	/**
	 * If `set_uid` is non-zero, the st_uid attribute of each file
	 * is overwritten with the value of `uid`.
	 */
	int set_uid;
	unsigned int uid;

	/**
	 * If `set_mode` is non-zero, the any permissions bits set in
	 * `umask` are unset in the st_mode attribute of each file.
	 */
	int set_mode;
	unsigned int umask;

	/**
	 * The timeout in seconds for which name lookups will be
	 * cached.
	 */
	doubl entry_timeout;
uu	/**
	 * The timeout in seconds for which a negative lookup will be
	 * cached. This means, that if file did not exist (lookup
	 * retuned ENOENT), the lookup will only be redone after the
	 * timeout, and the file/directory will be assumed to not
	 * exist until then. A value of zero means that negative
	 * lookups are not cached.
	 */
	double negative_timeout;

	/**
	 * The timeout in seconds for which file/directory attributes
	 * (as returned by e.g. the `getattr` handler) are cached.
	 */
	double attr_timeout;        // <<<<<

	/**
	 * Allow requests to be interrupted
	 */
	int intr;

	/**
	 * Specify which signal number to send to the filesystem when
	 * a request is interrupted.  The default is hardcoded to
	 * USR1.
	 */
	int intr_signal;

	/**
	 * Normally, FUSE assigns inodes to paths only for as long as
	 * the kernel is aware of them. With this option inodes are
	 * instead remembered for at least this many seconds.  This
	 * will require more memory, but may be necessary when using
	 * applications that make use of inode numbers.
	 *
	 * A number of -1 means that inodes will be remembered for the
	 * entire life-time of the file-system process.
	 */
	int remember;

	/**
	 * The default behavior is that if an open file is deleted,
	 * the file is renamed to a hidden file (.fuse_hiddenXXX), and
	 * only removed when the file is finally released.  This
	 * relieves the filesystem implementation of having to deal
	 * with this problem. This option disables the hiding
	 * behavior, and files are removed immediately in an unlink
	 * operation (or in a rename operation which overwrites an
	 * existing file).
	 *
	 * It is recommended that you not use the hard_remove
	 * option. When hard_remove is set, the following libc
	 * functions fail on unlinked files (returning errno of
	 * ENOENT): read(2), write(2), fsync(2), close(2), f*xattr(2),
	 * ftruncate(2), fstat(2), fchmod(2), fchown(2)
	 */
	int hard_remove;

	/**
	 * Honor the st_ino field in the functions getattr() and
	 * fill_dir(). This value is used to fill in the st_ino field
	 * in the stat(2), lstat(2), fstat(2) functions and the d_ino
	 * field in the readdir(2) function. The filesystem does not
	 * have to guarantee uniqueness, however some applications
	 * rely on this value being unique for the whole filesystem.
	 *
	 * Note that this does *not* affect the inode that libfuse 
	 * and the kernel use internally (also called the "nodeid").
	 */
	int use_ino;

	/**
	 * If use_ino option is not given, still try to fill in the
	 * d_ino field in readdir(2). If the name was previously
	 * looked up, and is still in the cache, the inode number
	 * found there will be used.  Otherwise it will be set to -1.
	 * If use_ino option is given, this option is ignored.
	 */
	int readdir_ino;

	/**
	 * This option disables the use of page cache (file content cache)
	 * in the kernel for this filesystem. This has several affects:
	 *
	 * 1. Each read(2) or write(2) system call will initiate one
	 *    or more read or write operations, data will not be
	 *    cached in the kernel.
	 *
	 * 2. The return value of the read() and write() system calls
	 *    will correspond to the return values of the read and
	 *    write operations. This is useful for example if the
	 *    file size is not known in advance (before reading it).
	 *
	 * Internally, enabling this option causes fuse to set the
	 * `direct_io` field of `struct fuse_file_info` - overwriting
	 * any value that was put there by the file system.
	 */
	int direct_io;

	/**
	 * This option disables flushing the cache of the file
	 * contents on every open(2).  This should only be enabled on
	 * filesystems, where the file data is never changed
	 * externally (not through the mounted FUSE filesystem).  Thus
	 * it is not suitable for network filesystems and other
	 * intermediate filesystems.
	 *
	 * NOTE: if this option is not specified (and neither
	 * direct_io) data is still cached after the open(2), so a
	 * read(2) system call will not always initiate a read
	 * operation.
	 *
	 * Internally, enabling this option causes fuse to set the
	 * `keep_cache` field of `struct fuse_file_info` - overwriting
	 * any value that was put there by the file system.
	 */
	int kernel_cache;

	/**
	 * This option is an alternative to `kernel_cache`. Instead of
	 * unconditionally keeping cached data, the cached data is
	 * invalidated on open(2) if if the modification time or the
	 * size of the file has changed since it was last opened.
	 */
	int auto_cache;

	/**
	 * The timeout in seconds for which file attributes are cached
	 * for the purpose of checking if auto_cache should flush the
	 * file data on open.
	 */
	int ac_attr_timeout_set;
	double ac_attr_timeout;

	/**
	 * If this option is given the file-system handlers for the
	 * following operations will not receive path information:
	 * read, write, flush, release, fsync, readdir, releasedir,
	 * fsyncdir, lock, ioctl and poll.
	 *
	 * For the truncate, getattr, chmod, chown and utimens
	 * operations the path will be provided only if the struct
	 * fuse_file_info argument is NULL.
	 */
	int nullpath_ok;

	/**
	 * The remaining options are used by libfuse internally and
	 * should not be touched.
	 */
	int show_help;
	char *modules;
	int debug;
};

//fuse.c
struct fuse *fuse_new_31(struct fuse_args *args,
		      const struct fuse_operations *op,
		      size_t op_size, void *user_data)
{
	struct fuse *f;
	struct node *root;
	struct fuse_fs *fs;
	struct fuse_lowlevel_ops llop = fuse_path_ops;

	f = (struct fuse *) calloc(1, sizeof(struct fuse));
	if (f == NULL) {
		fprintf(stderr, "fuse: failed to allocate fuse object\n");
		goto out;
	}

	f->conf.entry_timeout = 1.0;
	f->conf.attr_timeout = 1.0;            // <<<<<<
	f->conf.negative_timeout = 0.0;
	f->conf.intr_signal = FUSE_DEFAULT_INTR_SIGNAL;

	/* Parse options */
	if (fuse_opt_parse(args, &f->conf, fuse_lib_opts,
			   fuse_lib_opt_proc) == -1)
		goto out_free;

	pthread_mutex_lock(&fuse_context_lock);
	static int builtin_modules_registered = 0;
	/* Have the builtin modules already been registered? */
	if (builtin_modules_registered == 0) {
		/* If not, register them. */
		fuse_register_module("subdir", fuse_module_subdir_factory, NULL);
#ifdef HAVE_ICONV
		fuse_register_module("iconv", fuse_module_iconv_factory, NULL);
#endif
		builtin_modules_registered= 1;
	}
	pthread_mutex_unlock(&fuse_context_lock);

	if (fuse_create_context_key() == -1)
		goto out_free;

	fs = fuse_fs_new(op, op_size, user_data);
	if (!fs)
		goto out_delete_context_key;

	f->fs = fs;

	/* Oh f**k, this is ugly! */
	if (!fs->op.lock) {
		llop.getlk = NULL;
		llop.setlk = NULL;
	}

	f->pagesize = getpagesize();
	init_list_head(&f->partial_slabs);
	init_list_head(&f->full_slabs);
	init_list_head(&f->lru_table);

	if (f->conf.modules) {
		char *module;
		char *next;

		for (module = f->conf.modules; module; module = next) {
			char *p;
			for (p = module; *p && *p != ':'; p++);
			next = *p ? p + 1 : NULL;
			*p = '\0';
			if (module[0] &&
			    fuse_push_module(f, module, args) == -1)
				goto out_free_fs;
		}
	}

	if (!f->conf.ac_attr_timeout_set)
		f->conf.ac_attr_timeout = f->conf.attr_timeout;

#if defined(__FreeBSD__) || defined(__NetBSD__)
	/*
	 * In FreeBSD, we always use these settings as inode numbers
	 * are needed to make getcwd(3) work.
	 */
	f->conf.readdir_ino = 1;
#endif

	f->se = fuse_session_new(args, &llop, sizeof(llop), f);
	if (f->se == NULL)
		goto out_free_fs;
  //....
  //....
  //....
}

static int do_lookup(struct fuse *f, fuse_ino_t nodeid, const char *name,
		     struct fuse_entry_param *e)
{
	struct node *node;

	node = find_node(f, nodeid, name);
	if (node == NULL)
		return -ENOMEM;

	e->ino = node->nodeid;
	e->generation = node->generation;
	e->entry_timeout = f->conf.entry_timeout;
	e->attr_timeout = f->conf.attr_timeout;            // <<<<<<
	if (f->conf.auto_cache) {
		pthread_mutex_lock(&f->lock);
		update_stat(node, &e->attr);
		pthread_mutex_unlock(&f->lock);
	}
	set_stat(f, e->ino, &e->attr);
	return 0;
}

//fuse_kernel.h
struct fuse_entry_out {
	uint64_t	nodeid;		/* Inode ID */
	uint64_t	generation;	/* Inode generation: nodeid:gen must
					   be unique for the fs's lifetime */
	uint64_t	entry_valid;	/* Cache timeout for the name */
	uint64_t	attr_valid;	/* Cache timeout for the attributes */
	uint32_t	entry_valid_nsec;
	uint32_t	attr_valid_nsec;
	struct fuse_attr attr;
};

//fuse_lowlevel.h
/** Directory entry parameters supplied to fuse_reply_entry() */
struct fuse_entry_param {
	/** Unique inode number
	 *
	 * In lookup, zero means negative entry (from version 2.5)
	 * Returning ENOENT also means negative entry, but by setting zero
	 * ino the kernel may cache negative entries for entry_timeout
	 * seconds.
	 */
	fuse_ino_t ino;

	/** Generation number for this entry.
	 *
	 * If the file system will be exported over NFS, the
	 * ino/generation pairs need to be unique over the file
	 * system's lifetime (rather than just the mount time). So if
	 * the file system reuses an inode after it has been deleted,
	 * it must assign a new, previously unused generation number
	 * to the inode at the same time.
	 *
	 * The generation must be non-zero, otherwise FUSE will treat
	 * it as an error.
	 *
	 */
	uint64_t generation;

	/** Inode attributes.
	 *
	 * Even if attr_timeout == 0, attr must be correct. For example,
	 * for open(), FUSE uses attr.st_size from lookup() to determine
	 * how many bytes to request. If this value is not correct,
	 * incorrect data will be returned.
	 */
	struct stat attr;

	/** Validity timeout (in seconds) for inode attributes. If
	    attributes only change as a result of requests that come
	    through the kernel, this should be set to a very large
	    value. */
	double attr_timeout;

	/** Validity timeout (in seconds) for the name. If directory
	    entries are changed/deleted only as a result of requests
	    that come through the kernel, this should be set to a very
	    large value. */
	double entry_timeout;
};

//fuse_lowlevel.c
static void fill_entry(struct fuse_entry_out *arg,
		       const struct fuse_entry_param *e)
{
	arg->nodeid = e->ino;
	arg->generation = e->generation;
	arg->entry_valid = calc_timeout_sec(e->entry_timeout);
	arg->entry_valid_nsec = calc_timeout_nsec(e->entry_timeout);
	arg->attr_valid = calc_timeout_sec(e->attr_timeout);
	arg->attr_valid_nsec = calc_timeout_nsec(e->attr_timeout);
	convert_stat(&e->attr, &arg->attr);
}

```
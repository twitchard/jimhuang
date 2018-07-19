# OpenBSD Mastery ZFS

## Content

1. [Introduce](#Introducing)
2. [Virtual Devices](#Virtual%20Devices)
3. [Pools](#Pools)
4. [Datasets](#Datasets)
6. [Disk Space Management](#Disk%20Space%20Management)
7. [Snapshot and Clones](#Snapshot%20and%Clones)

## Introducing

ZFS combines the functions of traditional filesystems and volume
managers. As such, it expects to handle everything from the permis-
sions on individual files and which files are in which directories down
to tracking which storage devices get used for what purposes and how
that storage is arranged


- ZFS Datasets

ZFS filesystems aren’t exactly analogous to traditional filesystems,
and so are called datasets.

Each dataset has a name. A ZFS dataset name starts with the ZFS
storage pool, or zpool, the dataset is on.

A dataset’s children include snapshots,volumes, and child datasets.

- ZFS Partitions and Properties

ZFS lacks traditional partitions. A partition is a logical subdivision of
a disk, filling very specific Logical Block Addresses (LBAs) on a storage device.
Partitions have no awareness of the data on the partition.
Changing a partition means destroying and (presumably) rebuilding
the filesystem on top of it.

- ZFS Limits

ZFS advocates claim that ZFS is immune to these arbitrary limits,
but that’s not quite true. ZFS uses 128 bits to store most of its values,
which set the limits so high that they won’t ever be encountered by
anyone working in systems administration today. One directory can
have 2 48 files, of up to 16 exabytes each. A single pool can be up to 256
zettabytes, or 2 78 bytes. A storage pool can contain up to 2 64 devices,
and a single host can have up to 2 64 storage pools.

- Storage Pools

ZFS uses storage pools rather than disks. A storage pool is an abstrac-
tion atop the underlying storage providers, letting you separate the
physical medium and the user-visible filesystem on top of it.

- Virtual Devices

A storage pool contains one or more virtual devices, or VDEVs. A
VDEV is similar to a traditional RAID device. A big RAID-5 presents
itself to the filesystem layer as a single huge device, even though the
sysadmin knows it’s really a whole bunch of smaller disks. Virtual de-
vices let you assign specific devices to specific roles. With VDEVs you
can arrange the physical storage as needed.

ZFS’ data redundancy and automated error correction also take
place at the VDEV level

- Block and Inodes

Traditional filesystems almost always use some variety of data block
for storing data and maps the contents of those blocks with an index
node. BSD’s UFS and Linux’s extfs call these blocks and inodes. Even
Microsoft’s FAT filesystems have data storage blocks and index nodes.

Like these filesystems, ZFS uses index blocks and data blocks.
Unlike older filesystems, however, ZFS generates index nodes on de-
mand. Whenever possible, ZFS creates storage blocks in sizes that fit
the data. The variable sized blocks don’t always fit every possible file
you might create, but they’re certainly more flexible than traditional
filesystems.

## Virtual Devices

- Disks and Other Storage Media

ZFS can also run on storage media other than disks.
ZFS even has support for using files as the backing storage, which is
really great for testing but is not meant for production. ZFS can use
any block device for its physical storage, but each type has its advan-
tages and disadvantages.

- VDEVs: Virtual Devices

A virtual device, or VDEV, is the logical storage unit of ZFS.

- VDEV Redundancy

A VDEV that contains more than one disk can use a number of differ-
ent redundancy schemes to provide fault tolerance. Nothing can make
a single disk sitting all by itself redundant. ZFS supports using mir-
rored disks and several parity-based arrays.

ZFS uses redundancy to self-heal. A VDEV without redundancy
doesn’t support self-healing. You can work around this at the dataset
layer (with the copies property), but a redundant VDEV supports
self-healing automatically.

- Separate Intent Log (SLOG, ZIL)

ZFS maintains a ZFS Intent Log (ZIL) as part of the pool. Similar to
the journal in some other filesystems, this is where it writes in-prog-
ress operations, so they can be completed or rolled back in the event of
a system crash or power failure. The ZIL is subject to the disk’s normal
operating conditions. The pool might have a sudden spike in use or
latency related to load, resulting in slower performance.

One way to boost performance is to separate the ZIL from the
normal pool operations. You can use a dedicated device as a Separate
Intent Log, or SLOG, rather than using a regular part of the pool. The
dedicated device is usually a small but very fast device, such as a very
high-endurance SSD.

Rather than copying data from the SLOG to the pool’s main storage
in the order it’s received, ZFS can batch the data in sensible groups
and write it more efficiently.

Certain software insists on receiving confirmation that data it
writes to disk is actually on the disk before it proceeds. Databases of-
ten do this to avoid corruption in the event of a system crash or power
outage. Certain NFS operations do the same. By writing these requests
to the faster log device and reporting “all done,” ZFS accelerates these
operations. The database completes the transaction and moves on. You
get write performance almost at an SSD level, while using inexpensive
disk as the storage media.

- Cache (L2ARC)

When a file is read from disk, the system keeps it in memory until the
memory is needed for another purpose. This is old technology.
The traditional buffer cache was designed decades ago, howev-
er. ZFS has an Adaptive Replacement Cache, or ARC, designed for
modern hardware, that gives it more speed. The ARC retains the most
recently and frequently accessed files.

Very few modern systems have enough RAM to cache as much as
they want, however. Just as ZFS can use a SLOG to accelerate writes,
it can use a very fast disk to accelerate reads. This is called a Level 2
ARC, or L2ARC.

When an object is used frequently enough to benefit from caching,
but not frequently enough to rate being stored in RAM, ZFS can store
it on a cache device. The L2ARC is typically a very fast and high-en-
durance SSD or NVMe device. Now, when that block of data is re-
quested, it can be read from the faster SSD rather than the slower disks
that make up the rest of the pool. ZFS knows which data has been
changed on the back-end disk, so it can ensure that the read cache is
synchronized with the data on the storage pool.

## Pools

ZFS pools, or zpools, form the middle of the ZFS stack, connecting
the lower-level virtual devices to the user-visible filesystem. Pools are
where many filesystem-level tasks happen, such as allocating blocks
of storage. At the ZFS pool level you can increase the amount of space
available to your ZFS dataset, or add special virtual devices to improve
reading or writing performance.

- ZFS Blocks

Traditional filesystems such as UFS and extfs place data on the disk in
fixed-size blocks. The filesystem has special blocks, called inodes, that
index which blocks belong to which files.

ZFS does not pre-configure special index blocks. It only uses stor-
age blocks, also known as stripes. Each block contains index informa-
tion to link the block to other blocks on the disk in a tree. ZFS com-
putes hashes of all information in the block and stores the information
in the block and in the parent block. Each block is a complete unit in
and of itself. A file might be partially missing, but what exists is coher-
ent.

Not having dedicated special index blocks sounds great, but surely
ZFS needs to start somewhere! Every data tree needs a root. ZFS uses
a special block called an uberblock to store a pointer to the filesystem
root. ZFS never changes data on the disk—rather, when a block chang-
es, it writes a whole new copy of the block with the modified data.
A data pool reserves 128 blocks for uberblocks, used in sequence as the un-
derlying pool changes. When the last uberblock gets used, ZFS loops
back to the beginning

ZFS commits changes to the storage media in transaction groups,
or txg. Transaction groups contain several batched changes, and have
an incrementing 64-bit number. Each transaction group uses the next
uberblock in line. ZFS identifies the most current uberblock out of the
group of 128 by looking for the uberblock with the highest transaction
number.

ZFS does use some blocks for indexing, but these znodes and
dnodes can use any storage block in the pool. They aren’t like UFS2 or
extfs index nodes, assigned when creating the filesystem.

- Stripes, RAID, and Pools

You’ve certainly heard the word stripe in connection with storage,
probably many times. A ZFS pool “stripes” data across the virtual
devices. A traditional RAID “stripes” data across the physical devices.
What is a stripe, and how does it play into a pool?

A stripe is a chunk of data that’s written to a single device. Most
traditional RAID uses a 128 KB stripe size. When you’re writing a file
to a traditional RAID device, the RAID software writes to each drive
in 128 KB chunks, usually in parallel. Similarly, reads from a tradition-
al RAID array take place in increments of the stripe size.

Stripes do not provide any redundancy. Traditional RAID gets its
redundancy from parity and/or mirroring. ZFS pools get any redun-
dancy from the underlying VDEVs.

ZFS puts stripes on rocket-driven roller skates. A ZFS dataset uses
a default stripe size of 128 KB, but ZFS is smart enough to dynamically
change that stripe size to fit the equipment and the workload.

With ZFS, though, that virtual device can be any type of VDEV
ZFS supports. Take two VDEVs that are mirror pairs. Put them in
a single zpool. ZFS stripes data across them.

Remember, though, that pools do not provide any redundancy. All
ZFS redundancy comes from the underlying VDEVs.

- Pools Alignment and Disk Sector Size

ZFS expects to have an in-depth knowledge of the storage medium, in-
cluding the sector size of the underlying providers. If your pools don’t
use the correct sector size, or if ZFS’ sectors don’t align to the physi-
cal sectors on the disk, your storage performance will drop by half or
more.

- Partition Alignment

Disks report their sector size, so this isn’t a problem—except when it
is. Many disks report that they have 512-byte sectors, but they really
have 4096-byte (4K) sectors.

- ZFS Sector Size

ZFS defaults to assuming a 512-byte sector size. Using a 512-byte
filesystem sector size on a disk with physical 512-byte sectors is per-
fectly fine. Using a 512-byte filesystem sector on a 4K-sector disk
makes the hardware work harder. Assume you want to write 4 KB of
data on such a disk. Rather than telling the hard drive to write a single
physical sector, the hard drive is told to modify the first eighth of the
sector, then the second eighth, then the third, and so on. Doing a 512-
byte write to a 4 KB sector means reading the entire 4 KB, modifying
the small section, then writing it back. This is much slower than just
overwriting the entire sector.
If ZFS uses a 4K sector size on a disk with 512-byte sectors, the disk hardware
breaks up the access requests into physical sector sizes, at very little
performance cost.

While using a larger sector size does not impact performance, it
does reduce space efficiency when you’re storing many small files. If
you have a whole bunch of 1 KB files, each occupies a single sector.

ZFS sector size is a property of each virtual device in a pool.

Combined, these two facts mean that it’s almost always preferable
to force ZFS to use 4K sectors, regardless of the sector size reported by
the underlying disk. Using the larger ZFS sector size won’t hurt perfor-
mance except on certain specific database operations, and even then
only when using disks that really and for true use 512-byte sectors.

A pool variable called the ashift controls sector size. An ashift of 9
tells ZFS to use 512-byte sectors. An ashift of 12 tells ZFS to use 4096-
byte sectors.

- ZFS Integrity

Storage devices screw up.No filesystem can prevent errors in the
underlying hardware.

ZFS uses hashes almost everywhere. A hash is a mathematical al-
gorithm that takes a chunk of data and computes a fixed-length string
from it. The interesting thing about a hash is that minor changes in the
original data dramatically change the hash of the data. Each block of
storage includes the hash of its parent block, while each parent block
includes the hash of all its children.

While ZFS cannot prevent storage provider errors, it uses these
hashes to detect them. Whenever the system accesses data, it verifies
the checksums. ZFS uses the pool’s redundancy to repair any errors
before giving the corrected file to the operating system. This is called
self-healing.

If the underlying VDEV has no redundancy, and the dataset does
not keep extra copies, the pool notes that the file is damaged and re-
turns an error, instead of returning incorrect data. You can restore that
file from backup, or throw it away.

While ZFS performs file integrity checks, it also verifies the con-
nections between storage blocks.It’s a small part of data verification, and ZFS
performs this task continually as part of its normal operation.

- Scrubbing ZFS

A scrub of a ZFS pool verifies the cryptographic hash of every data
block in the pool. If the scrub detects an error, it repairs the error if
sufficient resiliency exists. Scrubs happen while the pool is online and
in use.

- Pool Properties

ZFS uses properties to express a pool’s characteristics. While zpool
properties look and work much like a dataset’s properties, and many
properties seem to overlap between the two, dataset properties have no
relationship to pool properties. Pool properties include facts such as
the pool’s health, size, capacity, and per-pool features.

A pool’s properties affect the entire pool. If you want to set a prop-
erty for only part of a pool, check for a per-dataset property that fits
your needs.

## Datasets

With ordinary filesystems you create partitions to separate different
types of data, apply different optimizations to them, and limit how
much of your space the partition can consume. Each partition receives
a specific amount of space from the disk.We’ve all been there. We
make our best guesses at how much disk space each partition on this
system will need next month, next year, and five years from now.

ZFS solves this problem by pooling free space, giving your parti-
tions flexibility impossible with more common filesystems. Each ZFS
dataset you create consumes only the space required to store the files
within it. Each dataset has access to all of the free space in the pool,
eliminating your worries about the size of your partitions. You can
limit the size of a dataset with a quota or guarantee it a minimum
amount of space with a reservation.

Regular filesystems use the separate partitions to establish different
policies and optimizations for the different types of data. /var contains
often-changing files like logs and databases. The root filesystem needs
consistency and safety over performance. Over in /home , anything
goes. Once you establish a policy for a traditional filesystem, though,
it’s really hard to change.

- Datasets

A dataset is a named chunk of data. This data might resemble a tradi-
tional filesystem, with files, directories, and permissions and all that
fun stuff. It could be a raw block device, or a copy of other data, or
anything you can cram onto a disk.

ZFS uses datasets much like a traditional filesystem might use par-
titions. Need a policy for /usr and a separate policy for /home ? Make
each a dataset. Need a block device for an iSCSI target? That’s a data-
set. Want a copy of a dataset? That’s another dataset.

Datasets have a hierarchical relationship. A single storage pool is
the parent of each top-level dataset. Each dataset can have child data-
sets. Datasets inherit many characteristics from their parent.

- Dataset Types

ZFS currently has five types of datasets: filesystems, volumes, snap-
shots, clones, and bookmarks.

A filesystem dataset resembles a traditional filesystem. It stores
files and directories. A ZFS filesystem has a mount point and supports
traditional filesystem characteristics like read-only, restricting setuid
binaries, and more. Filesystem datasets also hold other information,
including permissions, timestamps for file creation and modification.

A ZFS volume, or zvol, is a block device. In an ordinary filesystem,
you might create a file-backed filesystem for iSCSI or a special-pur-
pose UFS partition.

A snapshot is a read-only copy of a dataset from a specific point in
time. Snapshots let you retain previous versions of your filesystem and
the files therein for later use. Snapshots use an amount of space based
on the difference between the current filesystem and what’s in the
snapshot.

A clone is a new dataset based on a snapshot of an existing dataset,
allowing you to fork a filesystem. You get an extra copy of everything
in the dataset. You might clone the dataset containing your production
web site, giving you a copy of the site that you can hack on without
touching the production site. A clone only consumes space to store the
differences from the original snapshot it was created from.

- Why Do I Want Datasets?

You obviously need datasets. Putting files on the disk requires a filesys-
tem dataset. And you probably want a dataset for each traditional Unix
partition, like /usr and /var . But with ZFS, you want a lot of datasets.
Lots and lots and lots of datasets. This would be cruel madness with
a traditional filesystem, with its hard-coded limits on the number of
partitions and the inflexibility of those partitions

- ZFS Properties

ZFS datasets have a number of settings, called properties, that control
how the dataset works. While you can set a few of these only when you
create the dataset, most of them are tunable while the dataset is live.
ZFS also offers a number of read-only properties that provide informa-
tion such as the amount of space consumed by the dataset, the com-
pression or deduplication ratios, and the creation time of the dataset.
Each dataset inherits its properties from its parent, unless the
property is specifically set on that dataset.

- Filesystem Properties

One key tool for managing the performance and behavior of tradition-
al filesystems is mount options.

atime

A file’s atime indicates when the file was last accessed. ZFS’ atime
property controls whether the dataset tracks access times. The default
value, on, updates the file’s atime metadata every time the file is ac-
cessed.Using atime means writing to the disk every time it’s read.

- User-Defined Properties

ZFS properties are great, and you can’t get enough of them, right?
Well, start adding your own. The ability to store your own metadata
along with your datasets lets you develop whole new realms of auto-
mation. The fact that children automatically inherit these properties
makes life even easier.

- Parent/Child Relationships

Datasets inherit properties from their parent datasets. When you set a
property on a dataset, that property applies to that dataset and all of its
children.

- Mounting ZFS Filesystems

With traditional filesystems you listed each partition, its type, and
where it should be mounted in /etc/fstab.

Each ZFS filesystem has a mountpoint property that defines where
it should be mounted. The default mountpoint is built from the pool’s
mountpoint . If a pool doesn’t have a mount point, you must assign a
mount point to any datasets you want to mount.

- ZFS and /etc/fstab

You can choose to manage some or all of your ZFS filesystem mount
points with /etc/fstab if you prefer. Set the dataset’s mountpoint
property to legacy. This unmounts the filesystem.

- Dataset Integrity

Most of ZFS’ protections work at the VDEV layer.

Checksums

ZFS computes and stores checksums for every block that it writes. This
ensures that when a block is read back, ZFS can verify that it is the
same as when it was written, and has not been silently corrupted in
one way or another.Valid settings are on, fletcher2, fletcher4,
sha256, off, and noparity.

The standard algorithm, fletcher4, is the default checksum algo-
rithm. It’s good enough for most use and is very fast.

Copies

ZFS stores two or three copies of important metadata, and can give the
same treatment to your important user data.

- Metadata Redundancy

Each dataset stores an extra copy of its internal metadata, so that if a
single block is corrupted, the amount of user data lost is limited.

## Disk Space Management

ZFS makes it easy to answer questions like “How much free disk does
this pool have?” The question “What’s using up all my space?” is much
harder to answer thanks to snapshots, clones, reservations, ZVOLs,
and referenced data.

ZFS offers ways to improve disk space utilization. Rather than re-
quiring the system administrator to compress individual files, ZFS can
use compression at the filesystem level. ZFS can also perform dedupli-
cation of files, vastly improving disk usage at the cost of memory

- Reading ZFS Disk Usage

The df(1) program shows the amount of free space on each partition,
while du(1) shows how much disk is used in a partition or directory
tree.For decades, sysadmins have used these tools to see what’s eating
their free space. They’re great for traditional filesystems. ZFS requires
different ways of thinking, however.

- Referenced Data

The amount of data included in a dataset is the referenced data.
The referenced data is stuff that exists within this filesystem or
dataset. Multiple ZFS datasets can refer to the same collection
of data. That’s exactly how snapshots and clones work. That’s why ZFS
can hold, for example, several 10 GB snapshots in 11 GB of space.

- Freeing Space

In many ZFS deployments, deleting files doesn’t actually free up space.
In most situations, deletions actually increase disk space usage by a
tiny amount, thanks to snapshots and metadata. The space used by
those files gets assigned to the most recent snapshot.

On a filesystem using snapshots and clones, newly freed space
doesn’t appear immediately. Many ZFS operations free space asynchro-
nously, as ZFS updates all the blocks that refer to that space.

Those ISO files still exist in the older snapshots. ZFS knows that
the files don’t exist on the current dataset, but if you go look in the
snapshot directories you’ll see those files. ZFS must keep copies of
those deleted files for the older snapshots as long as the snapshots
refer to that data. Snapshots contents are read-only, so the only way to
remove those large files is to remove the snapshots.

- Pool Space Usage

Sometimes you don’t care about the space usage of individual datasets.
Only the space available to the pool as a whole matters. If you look at
a pool’s properties, you’ll see properties that look an awful lot like the
amount of space used and free.

- ZFS Compression

You can’t increase the size of an existing disk, but you can change how
your data uses that disk. For decades, sysadmins have compressed files
to make them take up less space. We’ve written all kinds of shell scripts
to run our preferred compression algorithm on the files we know can
be safely compressed, and we’re always looking for additional files that
can be compressed to save space.

## Snapshots and Clones

One of ZFS’ most powerful features is snapshots. A filesystem or
zvol snapshot allows you to access a copy of the dataset as it existed
at a precise moment. Snapshots are read-only, and never change. A
snapshot is a frozen image of your files, which you can access at your
leisure.

Snapshots are the root of many special ZFS features, such as
clones. A clone is a fork of a filesystem based on a snapshot. New
clones take no additional space, as they share all of their dataset blocks
with the snapshot. As you alter the clone, ZFS allocates new storage
to accommodate the changes.

Best of all, ZFS’ copy-on-write nature means that snapshots are
“free.” Creating a snapshot is instantaneous and consumes no addi-
tional space.

- Copy-on-Write

In both ordinary filesystems and ZFS, files exist as blocks on the disk.
In a traditional filesystem, changing the file means changing the file’s
blocks.If the system crashes or loses power when the system is actively
changing those blocks, the resulting shorn write creates a file that’s half
the old version, half the new, and probably unusable.

ZFS never overwrites a file’s existing blocks. When something
changes a file, ZFS identifies the blocks that must change and writes
them to a new location on the disk. This is called copy-on-write, or
COW. The old blocks remain untouched. A shorn write might lose
the newest changes to the file, but the previous version of the file still
exists intact.

Never losing a file is a great benefit of copy-on-write, but COW
opens up other possibilities. ZFS creates snapshots by keeping track of
the old versions of the changed blocks. That sounds deceptively simple,
doesn’t it? It is. But like everything simple, the details are complicated.

ZFS is almost an object-oriented filesystem. Metadata, indexing,
and data are all different types of objects that can point to other ob-
jects. A ZFS pool is a giant tree of objects, rooted in the pool labels.

Each disk in a pool contains four copies of the ZFS label: two at
the front of the drive and two at the end. Each label contains the pool
name, a Globally Unique ID (GUID), and information on each mem-
ber of the VDEV. Each label also contains 128 KB for uberblocks.

The uberblock is a fixed size object that contains a pointer to the
Meta Object Set (MOS), the number of the transaction group that
generated the uberblock, and a checksum.

The MOS records the top-level information about everything in
the pool, including a pointer to a list of all of the root datasets in the
pool. In turn each of these lists points to similar lists for their children,
and to blocks that describe the files and directories stored in the data-
set. ZFS chains these lists and pointer objects as needed for your data.
At the bottom of the tree, the leaf blocks contain the actual data stored
on the pool.

Every object contains a checksum and a birth time. The checksum
is used to make sure the object is valid. The birth time is the transac-
tion group (txg) number that created the block. Birth time is a critical
part of snapshot infrastructure.

Modifying a block of data touches the whole tree. The modified
block of data is written to a new location, so the block that points to it
is updated. This pointer block is also written to a new location, so the
next object up the tree needs updating. This percolates all the way up
to the uberblock.

The uberblock is the root of the tree. Everything descends from it.
ZFS can’t modify the uberblock without breaking the rules of copy-
on-write, so it rotates the uberblock.Each label reserves 128 KB for
uberblocks. Disks with 512-byte sectors have 128 uberblocks, while
disks with 4 KB sectors have 32 uberblocks. If you have a disk with 16
KB sectors, it will have only eight uberblocks. Each filesystem update
adds a new uberblock to this array. When the array fills up, the oldest
uberblock gets overwritten.

When the system starts, ZFS scans all of the uberblocks, finds the
newest one with a valid checksum, and uses that to import the pool.

- How Snapshots Work

When the administrator tells ZFS to create a snapshot, ZFS copies the
filesystem’s top-level metadata block.The live system uses the copy,
leaving the original for use by the snapshot. Creating the snapshot
requires copying only the one block, which means that ZFS can create
snapshots almost instantly. ZFS won’t modify data or metadata inside
the snapshot, making snapshots read-only. ZFS does record other
metadata about the snapshot, such as the birth time.

Snapshots also require a new piece of ZFS metadata, the dead list.
A dataset’s dead list records all the blocks that were used by the most
recent snapshot but are no longer part of the dataset. When you delete
a file from the dataset, the blocks used by that file get added to the
dataset’s dead list. When you create a snapshot, the live dataset’s dead
list is handed off to the snapshot and the live dataset gets a new, empty
dead list.

Deleting, modifying, or overwriting a file on the live dataset means
allocating new blocks for the new data and disconnecting blocks
containing old data. Snapshots need some of those old data blocks,
however. Before discarding an old block, the system checks to see if a
snapshot still needs it.

ZFS compares the birth time of the old data block with the birth
time of the most recent snapshot. Blocks younger than the snapshot
can’t possibly be used by that snapshot and can be tossed into the recy-
cle bin. Blocks older than the snapshot birth time are still used by the
snapshot, and so get added to the live dataset’s dead list.

After all this, a snapshot is merely a list of which blocks were in use
in the live dataset at the time the snapshot was taken. Creating a snap-
shot tells ZFS to preserve those blocks, even if the files that use those
blocks are removed from the live filesystem.

Deleting a snapshot requires comparing block birth times to
determine which blocks can now be freed and which are still in use. If
you delete the most recent snapshot, the dataset’s current dead list gets
updated to remove blocks required only by that snapshot.

Snapshots mean that data can stick around for a long time. If you
took a snapshot one year ago, any blocks with a birth date more than
a year ago are still in use, whether you deleted them 11 months ago or
before lunch today. Deleting a six-month-old snapshot might not free
up much space if the year-old snapshot needs most of those blocks. 1

Only once no filesystems, volumes, or snapshots use a block, does
it get freed.







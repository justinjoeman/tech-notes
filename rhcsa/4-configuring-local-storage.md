## Configuring local storage

### Manipulating disk partitions

**SCENARIO - add dedicated storage location to a web server for content and increase swap space**


#### Creating and mounting the partition

`fdisk` - used to list and manipulate a disk partition table

* Might want to do this under root. `fdisk -l` to list all disks. You can also do `fdisk -l <device>` to show the partitions on a particular disk eg `fdisk  -l /dev/sda` You might see something like:

```
root@justinjoeman-ubuntu:~# fdisk -l /dev/sda
Disk /dev/sda: 465.78 GiB, 500107862016 bytes, 976773168 sectors
Disk model: xxxxxx-xxxxxxxxxx
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: xxxxxxxxxxxxx-xxxxxxxxxxxxxx-xxxxxxxxxxxxxxx

Device         Start       End   Sectors   Size Type
/dev/sda1         34    262177    262144   128M Microsoft reserved
/dev/sda2     264192   1347583   1083392   529M Windows recovery environment
/dev/sda3    1347584   1550335    202752    99M EFI System
/dev/sda4    1550336 853893119 852342784 406.4G Microsoft basic data
/dev/sda5  853893120 923893759  70000640  33.4G Linux filesystem
/dev/sda6  923893760 939894783  16001024   7.6G Linux swap
/dev/sda7  939894784 976771071  36876288  17.6G Linux filesystem
```

You may also see a `*` next to the device name if it is the boot partition.

You may also see something like below which should in theory be empty space you can make use of:

```
Disk /dev/loop8: 54.24 MiB, 56872960 bytes, 111080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/loop9: 61.91 MiB, 64897024 bytes, 126752 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

* `gdisk` - An interactive GUID partition table (GPT) manipulator. You'll want to start this with something like `gdisk <diskname>` eg `gdisk /dev/loop9`

Once you are in the menu you can press `?` to show the help menu. `p` to show listed partitions

```
root@justinjoeman-ubuntu:~# gdisk /dev/loop9
GPT fdisk (gdisk) version 1.0.5

Partition table scan:
  MBR: not present
  BSD: not present
  APM: not present
  GPT: not present

Creating new GPT entries in memory.

Command (? for help): ?
b	back up GPT data to a file
c	change a partition's name
d	delete a partition
i	show detailed information on a partition
l	list known partition types
n	add a new partition
o	create a new empty GUID partition table (GPT)
p	print the partition table
q	quit without saving changes
r	recovery and transformation options (experts only)
s	sort partitions
t	change a partition's type code
v	verify disk
w	write table to disk and exit
x	extra functionality (experts only)
?	print this menu

Command (? for help): p
Disk /dev/loop9: 126752 sectors, 61.9 MiB
Sector size (logical/physical): 512/512 bytes
Disk identifier (GUID): B226EE6D-3ED4-416A-920F-FCC9619E3E18
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 33
First usable sector is 34, last usable sector is 126718
Partitions will be aligned on 2048-sector boundaries
Total free space is 126685 sectors (61.9 MiB)

Number  Start (sector)    End (sector)  Size       Code  Name

```

* From the above output  there are no listed partitions. I could now press `n` to add a new partition and accept the defaults to create a new partition. If I press `p` again I might see something like

```
Number  Start (sector)    End (sector)  Size       Code  Name
    1          2048         4194270       2.0 GiB   8300    Linux filesystem
```

* From here press `w` to write / save changes and exit the menu.

* You then want to put a file system on top of the device / partition you just created. You would use `mkfs` in order to do so. Use `man mkfs` to check the manual. At the bottom of the manual there is a mention that there are newer commands that should be used directly. For example using `mkfs.ext4 <device>` eg `mkfs.ext4 /dev/nvmeme1`

* After this you can use `mkdir` to make a directory for example `mkdir /web_content`.

* Then you want to mount your partition to your directory you made with something like `mount /dev/nvmeme1 /web_content`

* Finally test that it is mounted properly with `mount | grep web_content`

#### Changing the swap space

* Run `swapon` to see the current swapfile and how much size is available / used. So again you'd used `fdisk -l` to list your disks and find an empty partition and use `fdisk` to create an MBR partition.

* `fdisk <device>` and you'll enter into `fdisk` menu. Similar to `gdisk` in the way it works. `n` for new partition, follow the prompts.

On the `first sector` option best to accept the default.

On the `last sector` is where you make the change. `+` to add, `-` to shrink and then `K,M,G,T,P` for the unit. KB, MiB, GiB, TiB, PiB respectively. For example `+1G` to add `1 Gib` or `-5M` to shrink by `5 MiB`

* You may also need to change the partition type to make sure it is `swap`. While in the menu press `t` for type, then press `L` to list all the types available. For reference `82` is the Linux swap code.

* Enter the code, check it is correct with `p` to list the partitions, and once again save / exit with `w`.

* Next need to format your swap partition and can also give a label so it is clear what it is for. You can do this with `mkswap -L <label> <device>` eg `mkswap -L extra_swap /dev/nvmnm1`

* Then activate with `swapon <device>` eg `swapon /dev/nvmnm1`

`swapoff`, `mkswap`

### Managing mounted disks

*What is a persistent mount?* - Mounts that are configured automatically such as at boot time or when a request to mount all file systems is issued.

*Why are they important?* - This will ensure that the system is configured to survive routine processes, such as reboots.

*How to configure them?* - One way is to add the mounts to `/etc/fstab` to ensure persistence.

Use a device name that doesn't change such as `file system identifiers` and `device identifiers`

*File System identifiers* - Identifies a _file system on a block device_ using filesystem `UUID` or filesystem `Label`

*Device identifiers* - Identifies a _block device_ itself using World wide identifier (`WWID`), Partition `UUID` or Device `Serial Number`

`cat /etc/fstab` to take a look at the configuration file. Each line is a mount and each column separated by a space. On my Ubuntu machine it shows the headers for what each one means:

```
justin@justinjoeman-ubuntu:~/gitlab/tech-notes/rhcsa$ cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda5 during installation
UUID=ae2b10f9-9cbb-4996-a0cb-fdd1866634db /               ext4    errors=remount-ro 0       1
# /boot/efi was on /dev/sda3 during installation
UUID=593A-715A  /boot/efi       vfat    umask=0077      0       1
# /home was on /dev/sda7 during installation
UUID=b292e603-704e-4ae2-9859-77b77702187f /home           ext4    defaults        0       2
# swap was on /dev/sda6 during installation
UUID=13157c04-37f7-4d56-bd6c-455cf2a06000 none            swap    sw              0       0
```

#### What do the last two fields mean?

The `dump` column defines the backup option for the `dump` utility. It can be `0` or `1`.

The `Pass` column sets the check oder for the `fsck` utility. It can be `0`, `1` or `2`.

Using `0` will cause `dump` and `fsck` to skip this mount. Using `1` will make `dump` backup the filesystem and make `fsck` check with highest priority. Using `2` only applies to `fsck` and will make it check system with lowest priority.

**SCENARIO - we want to make some temporary mounts persistent eg a web project mount and some swap space**

* First you may want to find the device id of the mount you want to make persistent using `lsblk` to see your partition mount. Copy the name and then do `blkid | grep <name>` to get the `UUID`
* Copy `UUID`
* `vi /etc/fstab` to edit the config file
* Paste the `UUID` and enter the options to fit the format eg `UUID=b292e603-704e-4ae2-9859-77b77702187f /web_project           ext4    defaults        0       0`
* `wq` to save
* Remount it with something like `umount /web_project ; mount -a`
* Confirm has been remounted with something like `mount | grep web_project`
* Now with the swap space we would do `swapon` to check the status
* `swapoff <name>` to stop the swap
* `blkid | grep <label or name>` to get the `UUID` and then repeat the steps to edit and update `/etc/fstab`
* Then do something like `swapon -a` and it will add any persistent swap that isn't already mounted

### Using Local Volume Management (LVM)

#### LVM Basics

`Physical volumes` - These are generally the physical disks or a partition on a disk. For example having 2 SSD in a single machine.

`Volume Groups` - These are one or more physical volumes combined to create a pool of "physical extents" to allocate to one or more `logical volumes`. For example a single volume group may be a pool of storage shared on physical disk 1 and some on physical disk 2.

`Logical Volumes` - These are a set of logical extents that each map to one or more physical extents of the same size volume group.

**Working example** - 2 physical disks, A and B. We create a `volume group` across disks A and B. We then create 2 `logical volumes` on this volume group.

**SCENARIO - DBA team has run out of disk space! We will use LVM to do this**

* First we check what is available for us to use. We can do this with `lsblk` to list block devices, `fdisk` to check if anything is on them.
* `pvs` displays information about physical volumes.
* `pvcreate /dev/<empty_device>` for example `pvcreate /dev/nvme1n1` - will initialize physical device to be used with LVM
* Next we will create a volume group using the physical volume we just created.
* Use `vgs` to display information about volume groups.
* `vgcreate <name> <device>` to create a volume group. For example we would do `vgcreate db_storage /dev/nvme1n1`
* Next we create / format a logical volume.
* Use `lvs` to display information on logical volumes currently.
* Use `lvcreate -l 100%FREE -n <name_of_logical_volume> <volumegroup>` to create the volume. One example would be `lvcreate -l 100%FREE -n database1 db_storage`
* This will prompt to format the disk.
* Once done, you'll need to put your file storage on top of the LV you created. You can do this with something like `mkfs.ext4 /dev/mapper/db_storage-database1`
* Make a directory with `mkdir /database1` for example
* Be sure to make persistent as well and edit `/etc/fstab` to add `/dev/mapper/db_storage-database1` so it is mounted automatically. Once done do `mount -a`
* To extend the disk you would do `pvcreate <device>` with a free partition / disk. Then you'd do `vgextend <volumegroup_name> <pv>` for example `vgextend db_storage /dev/other_device`
* Next you need to extend the volume with `lvextend`. So you'd enter something like `lvextend -L +1G db_storage/database1` to extend this by 1GB.
* You also extend the filesystem storage as well to cover the new disk. You can do this with `resize2fs /dev/mapper/db_storage-database1`

If for whatever reason you needed to remove it. You'd basically work in reverse. You'd remove the logical group, then the volume group etc.

* First unmount the directory with `umount /dir` eg `umount /database1`
* Then do `lvremove db_storage/database1` and accept the prompts
* Remove the volumegroup with `vgremove -f db_storage` to tell it to just clobber it all
* Remove the physical volume as well with `pvremove`. For example `pvremove /dev/nvme1n1`

## Accessing Linux Systems

One way will be via console login. Need to have direct access to system.

`su` command - switch to another user

`sudo` - allows you to run commands as root / elevated privileges

`sudo passwd -u root` - this enables the root account

`sudo -i passwd root` - this will allow you to reset the root account password. *VERY IMPORTANT FOR EXAM!!!!*

If the networking on the server is already setup you'll be able to gain access remotely with the `ssh` command. This command allow remote logins, remote command execution, file transfers etc. You'll first need to generate an `ssh key`

### Generating a ssh key:

`ssh-keygen` to generate then you may want to do something like `ssh-copy-id user@anotherserver` to copy key to another server (requires remote user password).

Connecting to remote server with ssh - `ssh user@servername`

If you just want to run remote commands - `ssh user@servername commands` eg `ssh justin@justinjoeman cat /etc/hostname`

`ssh keys` are generally stored in `~/.ssh`

`eval $(ssh-agent -s)` - creates an ssh agent where you can then use `ssh-add` in order to add your keys and users. From here you can ssh to servers without being prompted for a password.

### Becoming root user / elevating privilege or switching users

Can become root with:

`su - root` or `su -` with no user listed. No user assumes root

`sudo -i` - then enter own password and become root. Kind of like a login shell

`sudo -k` - kills the time out so after you enter the password you won't need to re-enter it.

You can also become another user with sudo:

`sudo su - other_user` -> you'll be prompted for your local password and should work
if your account has permissions for it

### Other commands to remotely access system

`scp` - Secure copy. If we want to copy from the remote server to local server we would do something
like `scp remote_user@remote_server:/location_of_dir/* location_on_localserver`

`sftp` - Secure FTP. Run something like `sftp user@remote_server` - to connect then just browse  around like it is a shell. When files you want found - do `mget filename` - copies files to local machine

`ssh -t user@servername commands` - Executing a local command on a remote machine. For example if I was to run `ssh -t user@servername df -hT >> diskspace.txt` it would execute this on the remote server, but save the output on my local machine. Will say `connection closed` as it will close the connection after the command is run

## Using system documentation on RHEL 8

`man` - "Manual". Format is `man command` eg `man ssh`to view the manual for the command `ssh`. This is a traditional UNIX format and uses vim key bindings

`info` - information on a command. Format is `info command` eg `info ssh`. Default format for newer things. Uses emacs keybindings / commands

`usr/share/doc` - Files in this location contain docs. Come in many formats

`command --help` eg `ssh --help` - Often you can use a command and get the help directly with

`command -?` eg `ssh -?` - Another way to bring up the help page - doesn't always work

`whatis command` eg `whatis ssh`. Returned format is: `command manpage_number description`

```
justin@justinjoeman-ubuntu:~$ whatis ssh
ssh (1)              - OpenSSH remote login client
```

`apropos command` - pumps out more info

## Manipulating text files

`mkdir` -makes directory. `mkdir -p dir/parent/newdir` -> make directory and also parent directories if not existing

`touch filename` - Creates an empty file

`tree directory` - Shows directories as a tree. May need to install this utility first.

`grep string filename > another-file` - This will search the file `filename` for any lines with matches `string` and output the return to `another-file`. This will create file if it doesn't exist but also overwrite the contents of the file if it already exists.

`grep string filename > another-file 2> errors.log` - This will do the same as above but take standard output for errors (2) and redirect those to another file called `errors.log`

`some command > /dev/null` - Common redirection when you don't care about the output at all

`mv source destination`. Use `mv` to move a file to a different location or to rename a file

`>` - In redirection this will create a new file or overwrite a file with existing name

`>>` - In redirection this will append to a file if it already exists. If file doesn't exist it will create a new file and put the output in there.

`cp source destination` - Copy file(s) from source to destination.

`cat filename` - This will display the contents of a file on screen. If it could potentially be a long file it would be good to pair with or pipe to `grep` or `more` or `less`. Something like `cat system.log | grep error`

## Editing text files using vi or vim

Why `vi`? It's everywhere! `vi` might be your only option when you take the exam even if you're used to other editors.

Open file or create a file with `vi filename` eg `vi my-text-file`

Commands within `vi`:

`dd` - delete a line

`x` or `10 x` - deletes a character or 10 chars (respectively)

`O` - will put a new line in above the cursor
`o` - will put a new line in below the cursor

To start typing you need to press `insert` or `lower case i` and the screen will go into `insert mode`. From here navigate around and type as you normally would. Press `Esc` to exit out of edit mode to `command mode`.

When finished, make sure you are in `command mode`, press `:w` to write your changes to file, `:q` to exit file. You can also do that in one command eg `:wq`

If you wanted to save under a new filename you'd do `:w new_filename` and you should get a return response saying written.

To force quit - `:q!`

## Working with Linux files & permission links

Controlling access and permissions is important for security.

Differences between `hard link` and `soft link` are:

*Hard link*

* Additional name for existing file
* Can't be created for directories
* Can't cross file system boundaries or partitions
* Same `inode` number and permissions as original file

*Soft link* aka a symlink

* Special file that points to another file
* Can be created for directories
* Can cross file system boundaries and partitions
* Different `inode` number and file permissions than original
* Does not contain file data

Using `ll` or `ls -l` will show the permissions. Structure is like:

```
drwxrwxr-x 2 justin justin 4.0K Feb 17 22:13 ./
drwxrwxr-x 5 justin justin 4.0K Feb 17 21:49 ../
-rw-rw-r-- 1 justin justin 5.4K Feb 20 20:07 1-essential-rhel8-tools.md
```

Positions of the characters in the first column.

1 - Type. `d` for directory, `l` for links, `-` if normal file

2,3,4 - Owner permissions. `Read`, `Write`, `Execute` respectively

5,6,7 - Group permissions. `Read`, `Write`, `Execute` respectively

8,9,10 - Other (world) permissions. `Read`, `Write`, `Execute` respectively

11 - SELinux security context `.`. Any other alternative method (`+`)

`-` in general means "no flag set"

### Setting permissions

#### Octal method

`chmod 755 script.sh` - This will change the permissions on the file to give the owner full permissions, the group read/execute permissions and other read/execute. This method will be the following:

`4` - Read
`2` - Write
`1` - Execute.

So to give each collective read only permissions we would do `chmod 444 file`.

To make a script executable we could do something like `chmod 755 script.sh` as you need to be able to read it, plus execute it.

To make users & groups read/write but everyone else read only you'd do `chmod 664 filename`

Basically add up the permissions you need and that will be the final number.

#### Symbolic method

`chmod a+x script.sh`. Breakdown of command is `a` is the letter of the collective being changed (`u` - user, `g` - group, `o` - other, `a` - all. Same as using `chmod ugo`).

Next the `+` or `-` to add or remove permissions. Use `=` to set permissions exactly as you enter it

Then `wrx` in general to do `read`, `write`, `execute`. There are other special cases like `X` but won't go into these for now.

Examples:

`chmod ug=rw file.config` - This would set the `user` and `group` to have `read``write` permission but leave the `other` permissions intact

`chmod a-x file.config` - This would remove execute permission from all `user`,`group` and `other`

`chmod ug=rw,o= test.config` - This would set the final outcome to have `user` and `group` having `read`,`write` permissions, with `other` having no permissions.

#### Changing owners

`chown` is the command to use to change ownership of files / directories

`chown [OPTIONS] USER[:GROUP] file(s)` eg `chown -R justin:justin_group /var/justin/` would change the owner of the file to `justin` and the group to `justin_group`.

#### UMASK

This sets the permissions for new files / directories. UMASK values:

|umask value |file permissions |directory permissions |
|:-----------:|:----------------:|:---------------------:|
| 002 | -rw-rw-r-- | drwxrwxr-x |
| 007 | -rw-rw---- | drwxrwx--- |
| 022 | -rw-r--r-- | drwsr-xr-x |
| 027 | -rw-r----- | drwxr-x--- |
| 077 | -rw------ | drwx------ |

To set the umask you would type `umask value` eg `umask 022` which would subtract this from the base permissions. So if the base permission was `777`, with this umask the permissions would be `755`.

If you wanted to set the default umask you could do so in the `/etc/bashrc` or `/etc/profile` to set it for all users. Edit those files and append `umask 022` for example.

Default umask is `002` for normal users.

In short:

`022` only allows you to write data, but anyone can read.

`077` is good for a completely private system. Only owner can read / write data

## Compressing and decompressing files

*What is archiving?* This is the process of collecting and storing one or more files/directories into a single file. For archiving you can use the `tar` and `star` commands

*What is compression?* This is reducing the size of a file. For compression two popular commands are the `gzip` and `bzip` commands

Archiving and compression can be used together or separately.

`df -h` - shows disk free and with the `-h` switch will show output in a nice "human readable" form. Useful for general monitoring or if you are doing a before and after following some archiving and compression.

### Archiving

`tar cvf /location/of/archive/file.tar file1 file2 file3 log*` - This will `c`reate archive, command will be `v`erbose and will be in a `f`ile called `file.tar`. The commands after will add the files to the archive.

Alternatively you could do the same using `star` command:

`star -cv file=/location/of/archive/file.star file_or_directory` - similar to `tar`

You can view contents of an archive by running a command like `tar tvf archive.tar`. This will list (`t`) the contents of archive.

You can achieve the same with `star` by doing `star -tv file=archive.star`. Output looks a little different but contents should be same.

These commands will archive with no compression.

### Compressing

`gzip location/of/archive/file.tar` - This will compress the file with default options

`bzip location/of/archive/file.star` - This will compress the file with default options. `bzip` compresses more?


### Combining archiving and compression

To speed up time instead of doing individually the tools often offer a way to compress with a switch. For example:

`tar cvfz /output/archive.tar.gz file_or_directory` will use `gzip` compression at the time of archiving. It is a good idea to append with a filename as best practice so the file's purpose can be clear.

`star -cv -bz file=/output/archive.star.gz file_or_directory` - This will do the same as above.

### Extract and decompress

To extract a file you'd do a command like below. The extraction will be relative to where your `pwd` is so make sure you're in the directory you want to extract to:

`tar xvfj /output/archive.star.bz2` - `x` is for "extract", `j` is for using `bzip2` as part of the extraction. You could also use `z` to use `gzip` for it if the file name ended `.gz` for example.

If you wanted to decompress just a single file:

`bzip2 -d archive.bz2` to decompress the file into the `pwd`.

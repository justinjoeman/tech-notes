## Managing the boot process

### Linux boot process

* Server booted - `BIOS` loads and executes `POST`
* `BIOS` loads content of the MBR `Master Boot Record`
* `GRUB Bootloader` loads the kernal / provides which things you can boot into / edit boot options
* Kernal loads drivers and starts `systemd`
* `systemd` reads `/etc/systemd` config files and the `defult.target` file
* System brought to state as per the `default.target` file

When logged in, you can use `systemctl get-default` to see the current default target. If you have a GUI it is likely `graphical.target`

### SCENARIO - lost password for root user and need to reset it.

**VERY IMPORTANT FOR EXAM!!!** - Likely one of the first things you need to do so if you can't do you will get 0 marks!

* When logged in as a user who can reboot, open a terminal and type `sudo systemctl reboot` to reboot which should take us to the GRUB bootloader.
* Select boot device and press `e` to edit
* Go down to `linux` and press `ctrl + e` to go to end of line and type `rd.break`
* `ctrl + x` to start boot into emergency mode
* Then need to mount `/sysroot` by doing the command `mount -o rw,remount /sysroot`
* `chroot /sysroot`
* Now you can run the `passwd` command to set the root password. `passwd root`
* Set password
* Next you need to allow SElinux to auto relabel or you will have a system you can't boot. So you want to do `touch /.autorelabel`
* `exit` root shell
* Remount `sysroot` as `readonly` - `mount -o ro,remount /sysroot`
* `exit` to exit emergency mode
* May take a little while for system to boot
* Go back into the GRUB bootloader, press `e`, go to the line that starts with `linux`, press `ctrl + e` to go to end of line and then type `systemd.unit=multi-user.target` - this is a multi user system without the graphical interface. This will work just for that initial boot up you performed. If you were to reboot again it would likely go into the graphical interface. You can confirm this by running `systemctl get-default` and if the result is `graphical.target`
* Get to text based login and should be able to login now as `root`
* To permanently set it to get to the text based shell only you need to login as `root` and then run `system set-default multi-user`. You'll see it changing the target. Now when you reboot it will show you the shell.

## Understanding logging and using persistent journals

Log files are often kept in `/var/log` directory. However you can use the `systemd journal` to gather information and configure some persistence.

Types of logs:
* `/var/log` directory which is more "old school". Typically system and application logs
* `journalctl` - utility to query `systemd journal`
* `systemd-journalid` - used to log journals so they are persistent across reboots


### SCENARIO - need to configure logging on our new server to persist across reboots

**Very important for the exam** - Everything needs to be able to persist across reboots so anywhere you can enable persistence, do so!

Generally you would want to do this as `root` user so become root user with `sudo -i` and enter the password.

`/var/log/messages` - might be where the majority of things go

You can also use `journalctl -u cron` to find the journal entries containing `cron`. `-u` switch is for `unit`

`journalctl -g "kernal|systemd"` - this will search the journals and grep for `kernal` or `systemd`

If you wanted to search via a specified time frame you could do something like `journalctl -S 18:34:00 -U 19:04:00` which would search between the times `18:34:00 - 19:04:00`

Has an entry for each time the server is booted. You can see how many boots exist with `journalctl --list-boots`. Entry `0` is the latest journal.

If you wanted to view a particular boot journal you'd do `journalctl -b <id>` eg `journalctl -b 4` to boot the journal with the id `4`

```
justin@justinjoeman-ubuntu:~/gitlab/tech-notes/rhcsa$ journalctl --list-boots
-6 060a70d23a2441ea9c8951a5eb28ec5f Sun 2022-02-06 21:25:32 GMT—Sun 2022-02-06 21:45:29 GMT
-5 eaf24ff849cc4dd4934b6c6baab8e5d4 Sun 2022-02-06 21:45:44 GMT—Sat 2022-02-12 12:44:56 GMT
-4 2af790530c4f46f3b50c6ff1a78ab539 Sun 2022-02-13 01:36:14 GMT—Sun 2022-02-13 10:02:37 GMT
-3 8428444b8c134bdeb2f827b56dc02004 Sun 2022-02-13 15:54:37 GMT—Sat 2022-02-19 20:28:14 GMT
-2 03d04feca8a84f0ca4e21473c9298d87 Sun 2022-02-20 18:24:38 GMT—Wed 2022-02-23 10:00:11 GMT
-1 f43162c609144891bf40ef2c24ad6754 Wed 2022-02-23 18:50:18 GMT—Fri 2022-02-25 18:33:06 GMT
 0 b172c65f51024241b5bd8afd73226a9c Mon 2022-02-28 19:56:00 GMT—Thu 2022-03-03 21:02:45 GMT
```


By default, systemd logs to memory in the location `/run/log/journal`. So need to make persistent acrossd reboots as everything in RHCSA needs to be persistent across reboots

To see current storage setup you would do `cat /etc/systemd/journald.conf | grep -i storage` which will return something like `#Storage=auto`.

Logging modes for this parameter:
* `Volatile` - will be stored in `/run/log/journal` - NO PERSISTENCE
* `Persistent` - will be stored in `/var/log/journal` - PERSISTENT
* `None` - Storage data disabled, all data dropped! NO PERSISTENCE
* `Auto` - Default will be persistent if `/var/log/journal` exists, otherwise `Volatile`

So to set the persistence if your setting is `auto` is simply to `mkdir /var/log/journal` then do `journalctl --flush` to pick up the directory.

## Managing individual Linux processes

### SCENARIO - We have a runaway process that needs to be investigated / killed

Some commands that will help:
* `top` - for monitoring cpu
* `nice`, `renice` and `chrt` - for changing the process scheduling
* `pgrep` and `pkill` to terminate the process
* `iotop` - a simple "top" like I/O monitor. May need to be installed with `sudo yum install iotop` or `sudo dnf install iotop`

Using `top` to open up the process monitoring. Press `s` while in it to change the delay. Default appears to be `3`. Press `1` in order to toggle showing individual cpus vs summary of cpus. Press `t` in order to toggle the CPU display to show like a progress or utilisation bar. Press a few times to cycle through the types to bring you back to the original look. Press `m` in order to do the same for the memory.

From within `top` you can simply press `r` to `renice`, enter your process ID and then the number to change the scheduling. The default is `0`. `-20` is the *highest priority* and `19` is the *lowest priority*.

The `NI` column is the `nice value`

Using `renice` from the command line you'd do something like `renice -n <number> <pid>`

`chrt` will edit the real time attributes running of the process. You can do `chrt --max` to show you what types of scheduling queues and values you can set.

`chrt --help` to see the options but generally the following switches can be set:

```
Policy options:
 -b, --batch          set policy to SCHED_BATCH
 -d, --deadline       set policy to SCHED_DEADLINE
 -f, --fifo           set policy to SCHED_FIFO
 -i, --idle           set policy to SCHED_IDLE
 -o, --other          set policy to SCHED_OTHER
 -r, --rr             set policy to SCHED_RR (default)
```

`chrt -f -p <priority> <pid>` for example will set the `SCHED_FIFO`.

`pgrep` is like a "process grep" to get the PID of the processes. For example `pgrep bash` will grab the PIDs of the bash processes

```
justin@justinjoeman-ubuntu:~/gitlab/tech-notes/rhcsa$ pgrep bash
4559
justin@justinjoeman-ubuntu:~/gitlab/tech-notes/rhcsa$ ps
    PID TTY          TIME CMD
   4559 pts/1    00:00:00 bash
  35780 pts/1    00:00:00 ssh
  58756 pts/1    00:00:00 ps

```

`pkill` can be used in the same manner.

## Managing tuned profiles

The `tuned` service is an intelligent application that uses system monitoring to optimise system performance for specific types of workloads. Generally uses `profiles` which are customised for various use cases.

With the default profiles, the "best" is automatically selected during installation. Generally follow this format:

| Environment | Default profile | Goal |
| :---------: | :-------------: | :--: |
| Compute nodes | `throughput-performance` | Maximum throughput performance |
| Virtual Machines | `virtual-guest` | Maximum performance. Can also be use `balanced` or `powersave` profiles |
| Other | `balanced` | Balance of performance and energy savings |


**Key Locations**

`/etc/tuned/tuned-main.conf` - This is the main configuration file for `tuned`

`/etc/tuned` - Location for custom profiles. Overrides `/usr/lib/tuned` configurations with the same name.

`/usr/lib/tuned` - Distribution specific profiles. Each stored in its own sub directory. Each profile has its own `tuned.conf` file.

### Using tuned

`tuned-adm` is the command you use to interact with tuned.

`tuned-adm --help` - As always to bring up the help menu if one is built in.

`tuned-adm active` will show you the current active profile.

`tuned-adm list profiles` to see all the available profiles.

`tuned-adm profile <name>` to switch profile to the named one.

`tuned-adm recommend` will recommend the profile which it thinks is best.

You can try to use more than one profile by using `tuned-adm profile <name1> <name2>` eg `tuned-adm profile virutal-guest powersave` and it will attempt to merge them. When you then do `tuned-adm active` it should show you both profiles.

You can also do some "dynamic tuning". Take a look in the config file in `cat /etc/tuned/tuned-man.conf | grep dynamic_tuning` If the value is set to `0` it is disabled. Change this to `1` to enable it.

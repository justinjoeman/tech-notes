## Creating simple shell scripts

*What is a shell script?*

A script to run a command or a set of commands - basically all the tools and cli commands you can use except in a premade script format. Like powershell you can do for / while / if else statements etc

### Structure

```
#!/bin/bash    -> Header or interpreter to use to execute the script

# Comments you might want to add  
# For example basics of what the script does, arguments expected

ENVIRONMENT=$1    -> Setting global variables that are used from the command line input or expected
DIRS=$(ls /etc/webapps/$ENVIRONMENT)

# Main body of script to follow

if [ "$ENVIRONMENT" = ""]
then
    echo "No argument passed!"
    exit 10
else
    for DIR in $DIRS
    do
        echo "Backing up $ENVIRONMENT config: $DIR"
        tar -cvfz /var/backups/$ENVIRONMENT/$DIR.tar.gz /etc/webapps/$ENVIRONMENT/$DIR
    done
fi
```

### Permissions and naming convention

You need `read` and `execute` permissions to run a shell script.

Generally shell scripts will be appended with the `.sh` extension eg `script.sh`

## Bash scripting

[Placeholder - to add format for the various statements]

### Variables

* `MYVAR="Justin"` - sets
* `MYUSER=$(whoami)` - will execute the command `whoami` and return the output as the variable
* `INPUTFILE=$1` - variable will be the first argument passed into the shell script

### Comparison operaters

* `if [ $MYVAR == "Justin"]` - will check if variable matches the string
* `if [ $MYVAR != "Justin"]` - will check if variable does nor match the string
* Also have `>` and `<` when doing string comparisons

For numeric ones you'll have:
* `-lt` - less than
* `-gt` - greater than
* `-eq` - equal to
* `-ne` - not equal to
* `-le` - less or equal
* `-ge` - more or equal

#### If else statements

```
#!/bin/bash

# Prints a warning if over 80 and prints stable if less than or equal to 80

if [ $MYNUM -gt 80 ]
then
  echo "WARNING!"
  exit 10
elif [ $MYNUM -le 80 ]
  echo "STABLE!"
  exit 20
else
  echo "Didnt hit any of the conditional checks"
  exit 30
fi
```

#### For loop

```
#!/bin/bash

# Will print 1 2 3 as it is looping through

for i in 1 2 3; do
    echo $i
done
```

#### While loop

```
#!/bin/bash

# Echos the current counter number while it is less than 3

counter=0
while [ $counter -lt 3 ]; do
    let counter+=1
    echo $counter
done
```

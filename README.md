# backup-script

## Usage

Create a textfile containing one line for each backup task you have.
The format of each (non comment line) is:

~~~
{strategy} {name} {argument1} {argument2} ...
~~~

For example create a file 'backup.conf' with the content (make sure you `chmod 600`) it to protected protect contained passwords:

~~~
### configuration
# where to put the backup files
conf target /tmp/backup
# the passphase to encrypt the backup files with
# comment out the next line to disable encryption
conf passphrase applepie

### tasks
# backups all log files
folder logs /var/log
# backups the wordpress database
mysql wordpress-db wordpress_database wordpress_user SeCuRePaSsWoRd!
~~~

Now run the backup script with:

~~~ bash
$ ./backup.sh backup.conf
~~~

## Strategies

* `folder` Backups a folder into a compressed TAR ball.
* `mysql` Backups a MySQL database into a compressed SQL script.

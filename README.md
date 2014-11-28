# backup

## Usage

Create a textfile containing one line for each backup task you have.
The format of each (non comment line) is:

~~~
{strategy} {name} {argument1} {argument2} ...
~~~

For example create the file 'tasks.conf' with the content:

~~~
# backups all log files
folder logs /var/log

# backups the wordpress database
mysql wordpress-db wordpress_database wordpress_user SeCuRePaSsWoRd!
~~~

Now run the backup script with:

~~~ bash
$ ./backup.sh -v -t /path/to/backup/target tasks.conf
~~~

Optionally you can provide a password to encrypt the backup file with GPG:

~~~ bash
$ ./backup.sh -v -t /path/to/backup/target -p PaSsPhRaSe tasks.conf
~~~

## Strategies

* `folder` Backups a folder into a compressed TAR ball.
* `mysql` Backups a MySQL database into a compressed SQL script.

# backup-script

## Usage

Create a configuration file called 'backup.yaml' (make sure you `chmod 600` to proteced potentially contained sensible data). For example your configuration could look like this:

~~~ yaml
# put all backup files into /var/backup
target: /var/backup

# do not encrypt the resulting backup files
encryption:
  enabled: false
  passphrase:

# clean up all backup files older than 30 days
cleanup:
  enabled: true
  max-age: 2592000

backups:
  # backup the directory /var/logs
  logs:
    type: directory
    path: /var/log
  # backup the mysal database foobar_database
  foobar:
    type: mysql
    database: foobar_database
    user: foobar_user
    password: foobar_password
~~~

Now run the backup script like so:

~~~ bash
$ /path/to/main.py /path/to/backup.yml
~~~

To run the script on a regular basis (for example once a week on sunday, 3 a.m.) add one of the following lines as cron job (make sure that the cron job user has access to the directories):

~~~
# this way the cron job user gets an email every time the job has been run
0 3 * * 0 /path/to/main.py /path/to/backup.yml

# this way the cron job user only gets an email if something has been written to the stderr
0 3 * * 0 /path/to/main.py /path/to/backup.yml 1>/dev/null
~~~

## Backup strategies

* `directory` Backups a directory into a compressed TAR ball.
* `mysql` Backups a MySQL database into a compressed SQL script.

## Third party Python packages

You need the Python package [PyYAML](http://pyyaml.org/wiki/PyYAML). If you are using a recent version of [Ubuntu](http://www.ubuntu.com) you can install it by executing:

~~~ bash
$ sudo apt-get update
$ sudo apt-get install python-pip
$ sudo pip install pyyaml
~~~

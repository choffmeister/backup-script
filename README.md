# backup-script

## Usage

Create a configuration file called 'backup.yaml' (make sure you `chmod 600` to proteced potentially contained sensible data). For example your configuration could look like this:

~~~ yaml
target: /var/backup

encryption:
  enabled: false
  passphrase:

backups:
  logs:
    type: directory
    path: /var/logs
  wordpress/database:
    type: mysql
    database: wordpress_database
    user: wordpress_user
    password: wordpress_database
~~~

Now run the backup script like so:

~~~ bash
$ ./backup.py /path/to/backup.yml
~~~

## Strategies

* `directory` Backups a directory into a compressed TAR ball.
* `mysql` Backups a MySQL database into a compressed SQL script.

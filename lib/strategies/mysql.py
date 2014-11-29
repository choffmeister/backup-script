import lib.utils as utils

def backup(name, output_path, config):
  script = '%s.sql.gz' % output_path
  db = config['database']
  user = config['user']
  passw = config['password']

  utils.run_shell('mysqldump -u%s -p%s %s | gzip -9 > %s' % (user, passw, db, script))

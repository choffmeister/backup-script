import os
import re
import utils

def run(config):
  for backup_name in config['backups']:
    utils.log_info('starting backup %s' % backup_name)
    backup_config = config['backups'][backup_name]
    backup_type = backup_config['type']

    backup_output_dir = os.path.join(config['target'], backup_name)
    backup_output_name = '%s-%s' % (re.sub('[^0-9a-zA-Z]+', '-', backup_name), utils.timestamp('%Y-%m-%d_%H-%M-%S'))
    backup_output_path = os.path.join(backup_output_dir, backup_output_name)

    if backup_type == 'directory':
      utils.log_error('not yet implemented')
    elif backup_type == 'mysql':
      utils.log_error('not yet implemented')
    else:
      utils.log_error('unknown backup type %s' % backup_type)

    utils.log_info('finished backup %s' % backup_name)

  return 0

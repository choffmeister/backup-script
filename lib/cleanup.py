import os
import time
import lib.utils as utils

def run(config):
  utils.log_info('start cleanup')

  now = int(time.time())
  max_age = config['cleanup']['max-age']
  utils.log_info('removing all files that have not been altered in the last %d seconds' % max_age)

  files = map(lambda f: (f, os.path.getmtime(f) - now), utils.list_files(config['target']))
  files_old = filter(lambda f: f[1] < -max_age, files)
  for f in files_old:
    utils.log_info('remove %s' % f[0])
    os.remove(f[0])

  utils.log_info('finished cleanup')

import lib.utils as utils

def backup(name, output_path, config):
  archive = '%s.tar.gz' % output_path
  directory = config['path']

  utils.run(['tar', '-zcf', archive, '-C', directory, '.'])

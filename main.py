#!/usr/bin/python

import os
import sys
import yaml
from lib.backup import run as backup
from lib.cleanup import run as cleanup

current_dir = os.path.dirname(os.path.realpath(__file__))

if len(sys.argv) > 1:
  config_path = sys.argv[1]
else:
  config_path = os.path.join(current_dir, 'backup.yaml')

with open(config_path, 'r') as f:
  config = yaml.load(f)
  backup(config)
  cleanup(config)

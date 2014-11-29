#!/usr/bin/python

import os
import sys
import yaml
import lib.main as main

current_dir = os.path.dirname(os.path.realpath(__file__))

if len(sys.argv) > 1:
  config_path = sys.argv[1]
else:
  config_path = os.path.join(current_dir, 'backup.yaml')

with open(config_path, 'r') as f:
  config = yaml.load(f)
  exit_code = main.run(config)
  sys.exit(exit_code)

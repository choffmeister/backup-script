import sys
import os
import subprocess
import time
import datetime

def timestamp(format):
  now = time.time()
  return datetime.datetime.fromtimestamp(now).strftime(format)

def log_info(message):
  now = timestamp('%Y-%m-%d %H:%M:%S')
  print '[info] %s - %s' % (now, message)

def log_error(message):
  now = timestamp('%Y-%m-%d %H:%M:%S')
  print >> sys.stderr, '[error] %s - %s' % (now, message)

def ensure_directory(dir):
  if not os.path.exists(dir): os.makedirs(dir)

def run(cmd):
  subprocess.call(cmd)

def run_shell(cmd):
  p = subprocess.Popen(cmd, shell=True)
  p.communicate()

def list_files(dir):
  result = []
  for root, subFolders, files in os.walk(dir):
    for file in files:
        result.append(os.path.join(root, file))
  return result

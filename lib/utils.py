import sys
import os
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

def ensure_directroy(dir):
  if not os.path.exists(dir): os.makedirs(dir)

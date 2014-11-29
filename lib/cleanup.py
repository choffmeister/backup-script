import os
import time
import lib.utils as utils

def run(config):
  utils.log_info("start cleanup")
  #print "last modified: %s" % time.ctime(os.path.getmtime(file))
  #print "created: %s" % time.ctime(os.path.getctime(file))
  utils.log_info("finished cleanup")

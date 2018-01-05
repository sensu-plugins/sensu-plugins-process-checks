#!/usr/bin/env python
#
#  metrics-per-process.py
#
# DESCRIPTION:
#
# OUTPUT:
#   graphite plain text protocol
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#  Python 2.6+ (untested on Python3, should work though)
#  Python module: psutil https://pypi.python.org/pypi/psutil
#
# USAGE:
#
#  metrics-per-process.py -n <process_name> | -p <path_to_process_pid_file> | -u <username> [-s <graphite_scheme>] [-m <metrics_regexes>]
#
# NOTES:
# The plugin requires to read files in the /proc file system, make sure the owner
# of the sensu-client process can read /proc/<PIDS>/*
# When using a pid file make sure the owner of the sensu-client process can read
# it, normally a pid file lives in /var/run/ and only contains the process ID
#
# It gets extended stats (mem, cpu, threads, file descriptors, connections,
# i/o counters) from a process name or a process PID file path. If a process
# name is provided and multiple processes are running with that name then the
# stats are a sum of all the process with that name. When providing a PID file
# then a single process is being instrumented

# Sample output using sshd
#
# Using sshd as a process name (which finds all processes answering to name
# 'sshd' in /proc/<PIDS>/comm and then summing the stats)
#
# per_process_stats.io_counters.read_count 63513 1439159262
# per_process_stats.conns.tcp.total 10 1439159262
# per_process_stats.ctx_switches.voluntary 22171 1439159262
# per_process_stats.ctx_switches.involuntary 8631 1439159262
# per_process_stats.io_counters.write_bytes 212992 1439159262
# per_process_stats.memory.shared 20590592 1439159262
# per_process_stats.conns.unix_sockets.total 20 1439159262
# per_process_stats.memory.percent 0.478190140105 1439159262
# per_process_stats.memory.text 6746112 1439159262
# per_process_stats.memory.rss 29450240 1439159262
# per_process_stats.cpu.user 2.38 1439159262
# per_process_stats.fds 89 1439159262
# per_process_stats.memory.vms 945082368 1439159262
# per_process_stats.threads 9 1439159262
# per_process_stats.conns.tcp.established 8 1439159262
# per_process_stats.total_processes 9 1439159262
# per_process_stats.conns.tcp.listen 2 1439159262
# per_process_stats.cpu.system 3.8 1439159262
# per_process_stats.io_counters.write_count 24409 1439159262
# per_process_stats.io_counters.read_bytes 7811072 1439159262
# per_process_stats.memory.data 7778304 1439159262
#
# LICENSE:
#   Jaime Gago  contact@jaimegago.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

import os
import optparse
import psutil
import pwd
import re
import sys
import time

try:
  from collections import Counter
except ImportError:
  from backport_collections import Counter

PROC_ROOT_DIR = '/proc/'
TCP_CONN_STATUSES = [
'ESTABLISHED',
'SYN_SENT',
'SYN_RECV',
'FIN_WAIT1',
'FIN_WAIT2',
'TIME_WAIT',
'CLOSE',
'CLOSE_WAIT',
'LAST_ACK',
'LISTEN',
'CLOSING',
'NONE'
]
MEMORY_STATS = ['rss', 'vms', 'shared', 'text', 'lib', 'data', 'dirty']

def find_pids(matcher):
  '''Find process PID using /proc/<pids> with given matcher'''

  pids_in_proc = [ pid for pid in os.listdir(PROC_ROOT_DIR) if pid.isdigit() ]
  pids = []
  for pid in pids_in_proc:
    path = PROC_ROOT_DIR + pid
    try:
      if matcher(path):
        pids.append(int(pid))
    except OSError, e:
      if e.errno == 2:
        pass
  return pids

def find_pids_from_name(process_name):
  '''Find process PID from name using /proc/<pids>/comm'''

  def matcher(path):
    if 'comm' in os.listdir(path):
      file_handler = open(path + '/comm', 'r')
      return file_handler.read().rstrip() == process_name

  return find_pids(matcher)

def find_pids_from_user(username):
  '''Find process PID from username using ownership of /proc/<pids>'''

  try:
    user = pwd.getpwnam(username)
    uid = user.pw_uid
  except KeyError:
    return []

  def matcher(path):
    stat = os.stat(path)
    return stat.st_uid == uid

  return find_pids(matcher)

def additional_stats(process_handler, metrics_regexp):
  stats = {}

  if metrics_regexp.match('cpu.user'): 
    stats['cpu.user'] = process_handler.cpu_times().user

  if metrics_regexp.match('cpu.system'): 
    stats['cpu.system'] = process_handler.cpu_times().system

  if metrics_regexp.match('cpu.percent'): 
    stats['cpu.percent'] = process_handler.cpu_percent()

  if metrics_regexp.match('threads'): 
    stats['threads'] = process_handler.num_threads()

  if metrics_regexp.match('memory.percent'): 
    stats['memory.percent'] = process_handler.memory_percent()

  if metrics_regexp.match('fds'): 
    stats['fds'] = process_handler.num_fds()

  if metrics_regexp.match('ctx_switches.voluntary'): 
    stats['ctx_switches.voluntary'] = process_handler.num_ctx_switches().voluntary

  if metrics_regexp.match('ctx_switches.involuntary'): 
    stats['ctx_switches.involuntary'] = process_handler.num_ctx_switches().involuntary

  if metrics_regexp.match('io_counters.read_count'): 
    stats['io_counters.read_count'] = process_handler.io_counters().read_count

  if metrics_regexp.match('io_counters.write_count'): 
    stats['io_counters.write_count'] = process_handler.io_counters().write_count

  if metrics_regexp.match('io_counters.read_bytes'): 
    stats['io_counters.read_bytes'] = process_handler.io_counters().read_bytes

  if metrics_regexp.match('io_counters.write_bytes'): 
    stats['io_counters.write_bytes'] = process_handler.io_counters().write_bytes

  return stats

# Memory info
def memory_stats(process_handler, metrics_regexp):
  if psutil.version_info < (4,0,0):
    process_memory_info = process_handler.memory_info_ex()
  else:
    process_memory_info = process_handler.memory_info()

  stats = {}
  for stat in MEMORY_STATS:
    if metrics_regexp.match('memory.' + stat):
      stats['memory.' + stat] = getattr(process_memory_info, stat)

  return stats

# TCP/UDP/Unix Socket Connections
def connection_stats(process_handler, metrics_regexp):
  tcp_stats = ['total'] + [s.lower() for s in TCP_CONN_STATUSES]
  tcp_conns = None
  tcp_conns_count = {}
  for stat in tcp_stats:
    if metrics_regexp.match('conns.tcp.' + stat):
      if tcp_conns is None:
        tcp_conns = process_handler.connections(kind='tcp')

  stats = {}
  if tcp_conns:
    stats['conns.tcp.total'] = len(tcp_conns)
    for tcp_status in TCP_CONN_STATUSES:
      stat = 'conns.tcp.' + tcp_status.lower()
      if metrics_regexp.match(stat):
        tcp_conns_count[stat] = 0
        for conn in tcp_conns:
          if conn.status == tcp_status:
            tcp_conns_count[stat] = tcp_conns_count[stat] + 1
    stats.update(tcp_conns_count)

  if metrics_regexp.match('conns.udp.total'):
    udp_conns = process_handler.connections(kind='udp')
    if udp_conns:
      stats['conns.udp.total'] = len(udp_conns)

  if metrics_regexp.match('conns.unix_sockets.total'):
    unix_conns = process_handler.connections(kind='unix')
    if unix_conns:
      stats['conns.unix_sockets.total'] = len(unix_conns)

  return stats

def stats_per_pid(pid, metrics_regexes):
  '''Gets process stats using psutil module

  Returns only the stats with a name that matches one of the metrics_regexes
  details at http://pythonhosted.org/psutil/#process-class'''

  stats = {}
  process_handler = psutil.Process(pid)

  for metrics_regexp in metrics_regexes:
    stats.update(memory_stats(process_handler, metrics_regexp))
    stats.update(connection_stats(process_handler, metrics_regexp))
    stats.update(additional_stats(process_handler, metrics_regexp))

  return stats

def multi_pid_process_stats(pids, metrics_regexes):
  stats = {'total_processes': len(pids)}
  for pid in pids:
    stats = Counter(stats) + Counter(stats_per_pid(pid, metrics_regexes))
  return stats

def recursive_dict_sum(dictionnary):
  sum_dict = Counter(dictionnary) + Counter(dictionnary)
  recursive_dict_sum(sum_dict)
  return sum_dict

def graphite_printer(stats, graphite_scheme):
  now = time.time()
  for stat in stats:
    print "%s.%s %s %d" % (graphite_scheme, stat, stats[stat], now)

def get_pid_from_pid_file(pid_file):
  try:
    file_handler = open(pid_file, 'r')
  except Exception as e:
    print 'could not read: %s' % pid_file
    print e
    sys.exit(1)
  try:
    pid = [].append(int(file_handler.read().rstrip()))
  except Exception as e:
    print 'It seems file : %s, does not use standard pid file convention' % pid_file
    print 'Pid file typically just contains the PID of the process'
    print e
    sys.exit(1)
  return pid

def main():
  parser = optparse.OptionParser()

  parser.add_option('-n', '--process-name',
    help    = 'name of process to collect stats (imcompatible with -p or -u)',
    dest    = 'process_name',
    metavar = 'PROCESS_NAME')

  parser.add_option('-p', '--pid-file',
    help    = 'path to pid file for process to collect stats (imcompatible with -n or -u)',
    dest    = 'process_pid_file',
    metavar = 'PROCESS_PID_FILE')

  parser.add_option('-u', '--user',
    help    = 'username of user running the process to collect stats (incompatible with -n or -p)',
    dest    = 'username',
    metavar = 'USERNAME')

  parser.add_option('-s', '--graphite_scheme',
    help    = 'graphite scheme to prepend, default to <process_stats>',
    default = 'per_process_stats',
    dest    = 'graphite_scheme',
    metavar = 'GRAPHITE_SCHEME')

  parser.add_option('-m', '--metrics-regexes',
    help    = 'comma-separated list of regexes used to match the metric names to collect, default to .*',
    default = '.*',
    dest    = 'metrics_regexes',
    metavar = 'METRICS_REGEXES')

  (options, args) = parser.parse_args()
  options_list = [options.process_name, options.process_pid_file, options.username]
  options_count = len(filter(lambda x: x is not None, options_list))

  if options_count > 1:
    print 'Specify a process name or a process pid file path or username, but only one of them'
    sys.exit(1)

  if options_count == 0:
    print 'A process name or a process pid file path or username is needed'
    sys.exit(1)

  options.metrics_regexes = [re.compile(regex) for regex in options.metrics_regexes.split(',')]

  if options.process_name:
    pids = find_pids_from_name(options.process_name)
    graphite_printer(multi_pid_process_stats(pids, options.metrics_regexes), options.graphite_scheme)

  if options.username:
    pids = find_pids_from_user(options.username)
    graphite_printer(multi_pid_process_stats(pids, options.metrics_regexes), options.graphite_scheme)

  if options.process_pid_file:
    pid = get_pid_from_pid_file(options.process_pid_file)
    graphite_printer(stats_per_pid(pid, options.metrics_regexes), options.graphite_scheme)
#
if __name__ == '__main__':
  main()

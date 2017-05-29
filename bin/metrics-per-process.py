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
#  metrics-per-process.py -n <process_name> | -p <path_to_process_pid_file> [-s <graphite_scheme>]
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

def find_pids_from_name(process_name):
  '''Find process PID from name using /proc/<pids>/comm'''

  pids_in_proc = [ pid for pid in os.listdir(PROC_ROOT_DIR) if pid.isdigit() ]
  pids = []
  for pid in pids_in_proc:
    path = PROC_ROOT_DIR + pid
    try:
        if 'comm' in os.listdir(path):
          file_handler = open(path + '/comm', 'r')
          if file_handler.read().rstrip() == process_name:
            pids.append(int(pid))
    except OSError, e:
        if e.errno == 2:
            pass
  return pids

def stats_per_pid(pid):
  '''Gets process stats using psutil module

  details at http://pythonhosted.org/psutil/#process-class'''

  stats = {}
  process_handler = psutil.Process(pid)
  if psutil.version_info < (4,0,0):
    process_memory_info = process_handler.memory_info_ex()
  else:
    process_memory_info = process_handler.memory_info()
  stats['cpu.user'] = process_handler.cpu_times().user
  stats['cpu.system'] = process_handler.cpu_times().system
  stats['cpu.percent'] = process_handler.cpu_percent()
  stats['threads'] = process_handler.num_threads()
  stats['memory.rss'] = process_memory_info.rss
  stats['memory.vms'] = process_memory_info.vms
  stats['memory.shared'] = process_memory_info.shared
  stats['memory.text'] = process_memory_info.text
  stats['memory.lib'] = process_memory_info.lib
  stats['memory.data'] = process_memory_info.data
  stats['memory.dirty'] = process_memory_info.dirty
  stats['memory.percent'] = process_handler.memory_percent()
  stats['fds'] = process_handler.num_fds()
  stats['ctx_switches.voluntary'] = process_handler.num_ctx_switches().voluntary
  stats['ctx_switches.involuntary'] = process_handler.num_ctx_switches().involuntary
  stats['io_counters.read_count'] = process_handler.io_counters().read_count
  stats['io_counters.write_count'] = process_handler.io_counters().write_count
  stats['io_counters.read_bytes'] = process_handler.io_counters().read_bytes
  stats['io_counters.write_bytes'] = process_handler.io_counters().write_bytes
  # TCP/UDP/Unix Socket Connections
  tcp_conns = process_handler.connections(kind='tcp')
  if tcp_conns:
    stats['conns.tcp.total'] = len(tcp_conns)
    tcp_conns_count = {}
    for tcp_status in TCP_CONN_STATUSES:
      tcp_conns_count['conns.tcp.' + tcp_status.lower()] = 0
      for conn in tcp_conns:
        if conn.status == tcp_status:
          tcp_conns_count['conns.tcp.' + tcp_status.lower()] = tcp_conns_count[
              'conns.tcp.' + tcp_status.lower()] + 1
    stats.update(tcp_conns_count)
  udp_conns = process_handler.connections(kind='udp')
  if udp_conns:
    stats['conns.udp.total'] = len(udp_conns)
  unix_conns = process_handler.connections(kind='unix')
  if unix_conns:
    stats['conns.unix_sockets.total'] = len(unix_conns)
  return stats

def multi_pid_process_stats(pids):
  stats = {'total_processes': len(pids)}
  for pid in pids:
    stats = Counter(stats) + Counter(stats_per_pid(pid))
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
    help    = 'name of process to collect stats (imcompatible with -p)',
    dest    = 'process_name',
    metavar = 'PROCESS_NAME')

  parser.add_option('-p', '--pid-file',
    help    = 'path to pid file for process to collect stats (imcompatible with -n)',
    dest    = 'process_pid_file',
    metavar = 'PROCESS_PID_FILE')

  parser.add_option('-s', '--graphite_scheme',
    help    = 'graphite scheme to prepend, default to <process_stats>',
    default = 'per_process_stats',
    dest    = 'graphite_scheme',
    metavar = 'GRAPHITE_SCHEME')

  (options, args) = parser.parse_args()

  if options.process_name and options.process_pid_file:
    print 'Specify a process name or a process pid file path, but not both'
    sys.exit(1)

  if not options.process_name and not options.process_pid_file:
    print 'A process name or a process pid file path is needed'
    sys.exit(1)

  if options.process_name:
    pids = find_pids_from_name(options.process_name)
    graphite_printer(multi_pid_process_stats(pids), options.graphite_scheme)

  if options.process_pid_file:
    pid = get_pid_from_pid_file(options.process_pid_file)
    graphite_printer(stats_per_pid(pid), options.graphite_scheme)
#
if __name__ == '__main__':
  main()

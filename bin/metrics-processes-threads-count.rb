#! /usr/bin/env ruby
#
#   metric-processes-threads-count.rb
#
# DESCRIPTION:
#   Counts the number of processes running on the system (and optionally, the number of running threads) and outputs it in metric format.
#   Can alternatively count the number of processes/threads matching a certain substring.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux, Windows
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: sys-proctable
#
# USAGE:
#   Pass [-t|--threads] to count the number of running threads in addition to processes.
#   The check will return an UNKNOWN if the sys-proctable version is not new enough to support counting threads.
#
# NOTES:
#   sys-proctable > 0.9.5 is required for counting threads (-t, --threads)
#
# LICENSE:
#   Copyright (c) 2015 Contegix LLC
#   Richard Chatteron richard.chatterton@contegix.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'sys/proctable'
require 'socket'

#
# Processes and Threads Count Metrics
#
class ProcessesThreadsCount < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Scheme for metric output',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.system"

  option :threads,
         description: 'If specified, count the number of threads running on the system in addition to processes. Note: Requires sys-proctables > 0.9.5',
         short: '-t',
         long: '--threads',
         boolean: true,
         default: false

  option :statuses,
         description: 'If specified, count each process number by status in addition to processes. Note: Requires sys-proctables > 0.9.5',
         short: '-S',
         long: '--statuses',
         boolean: true,
         default: false

  PROCTABLE_MSG = 'sys-proctable version newer than 0.9.5 is required for counting threads with -t or --threads'.freeze

  # Exit with an unknown if sys-proctable is not high enough to support counting threads.
  def check_proctable_version
    Gem.loaded_specs['sys-proctable'].version > Gem::Version.create('0.9.5')
  end

  # Takes a value to be tested as an integer. If a new Integer instance cannot be created from it, return 1.
  # See the comments on get_process_threads() for why 1 is returned.
  def test_int(i)
    return Integer(i)
  rescue
    return 1
  end

  # Takes a process struct from Sys::ProcTable.ps() as an argument
  # Attempts to use the Linux thread count field :nlwp first, then tries the Windows field :thread_count.
  # Returns the number of processes in those fields.
  # Otherwise, returns 1 as all processes are assumed to have at least one thread.
  def get_process_threads(p)
    if p.respond_to?(:nlwp) # rubocop:disable Style/GuardClause
      return test_int(p.nlwp)
    elsif p.respond_to?(:thread_count)
      return test_int(p.thread_count)
    else
      return 1
    end
  end

  def count_threads(ps_table)
    ps_table.reduce(0) do |sum, p|
      sum + get_process_threads(p)
    end
  end

  # Takes a process struct from Sys::ProcTable.ps() as an argument
  # Initialises a list of different Linux process statuses
  # Tries to use the Linux proccess status :state field, returns the initializedl list if it fails
  # Counts the processes by status and returns the hash
  def count_processes_by_status(ps_table)
    list_proc = {}
    %w(S R D T t X Z).each do |v|
      list_proc[v] = 0
    end
    if ps_table.first.respond_to?(:state)
      ps_table.each do |pr|
        list_proc[pr[:state]] += 1
      end
    end
    list_proc
  end

  # Main function
  def run
    if config[:threads] || config[:statuses]
      unknown PROCTABLE_MSG unless check_proctable_version
    end
    ps_table = Sys::ProcTable.ps
    processes = ps_table.length
    threads = count_threads(ps_table) if config[:threads]

    timestamp = Time.now.to_i
    output "#{[config[:scheme], 'process_count'].join('.')} #{processes} #{timestamp}"
    if config[:threads]
      output "#{[config[:scheme], 'thread_count'].join('.')} #{threads} #{timestamp}"
    end
    if config[:statuses]
      count_processes_by_status(ps_table).each do |type, proc_count|
        case type
        when 'S'
          output "#{[config[:scheme], 'sleeping'].join('.')} #{proc_count} #{timestamp}"
        when 'R'
          output "#{[config[:scheme], 'running'].join('.')} #{proc_count} #{timestamp}"
        when 'D'
          output "#{[config[:scheme], 'ininterruptible_sleep'].join('.')} #{proc_count} #{timestamp}"
        when 'T'
          output "#{[config[:scheme], 'stopped'].join('.')} #{proc_count} #{timestamp}"
        when 't'
          output "#{[config[:scheme], 'stopped_by_debugger'].join('.')} #{proc_count} #{timestamp}"
        when 'X'
          output "#{[config[:scheme], 'dead'].join('.')} #{proc_count} #{timestamp}"
        when 'Z'
          output "#{[config[:scheme], 'zombie'].join('.')} #{proc_count} #{timestamp}"
        end
      end
    end
    ok
  end
end

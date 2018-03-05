#! /usr/bin/env ruby
#
#   check-threads-count.rb
#
# DESCRIPTION:
#   Counts the number of threads running on the system and alerts if that number is greater than the warning or critical values.
#   The default warning and critical count thresholds come from the ~32000 thread limit in older Linux kernels.
#
# OUTPUT:
#   check
#
# PLATFORMS:
#   Linux, Windows
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: sys-proctable
#
# USAGE:
#   The check will return an UNKNOWN if the sys-proctable version is not new enough to support it.
#
# NOTES:
#   sys-proctable > 0.9.5 is required for counting threads
#
# LICENSE:
#   Copyright (c) 2015 Contegix LLC
#   Richard Chatteron richard.chatterton@contegix.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'sys/proctable'

#
# Check Threads Count
#
class ThreadsCount < Sensu::Plugin::Check::CLI
  option :warn,
         description: 'Produce a warning if the total number of threads is greater than this value.',
         short: '-w WARN',
         default: 30_000,
         proc: proc(&:to_i)

  option :crit,
         description: 'Produce a critical if the total number of threads is greater than this value.',
         short: '-c CRIT',
         default: 32_000,
         proc: proc(&:to_i)

  # Takes a value to be tested as an integer. If a new Integer instance cannot be created from it, return 1.
  # See the comments on get_process_threads() for why 1 is returned.
  def test_int(i)
    Integer(i)
  rescue TypeError
    1
  rescue ArgumentError
    1
  rescue StandardError
    1
  end

  # Takes a process struct from Sys::ProcTable.ps() as an argument
  # Attempts to use the Linux thread count field :nlwp first, then tries the Windows field :thread_count.
  # Returns the number of processes in those fields.
  # Otherwise, returns 1 as all processes are assumed to have at least one thread.
  def get_process_threads(p)
    if p.respond_to?(:nlwp)
      test_int(p.nlwp)
    elsif p.respond_to?(:thread_count)
      test_int(p.thread_count)
    else
      1
    end
  end

  def count_threads
    ps_table = Sys::ProcTable.ps
    ps_table.reduce(0) do |sum, p|
      sum + get_process_threads(p)
    end
  end

  # Main function
  def run
    threads = count_threads
    critical "#{threads} threads running, over threshold #{config[:crit]}" if threads > config[:crit]
    warning "#{threads} threads running, over threshold #{config[:warn]}" if threads > config[:warn]
    ok "#{threads} threads running"
  end
end

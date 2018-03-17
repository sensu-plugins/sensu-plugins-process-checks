#! /usr/bin/env ruby
#
# check-process
#
# DESCRIPTION:
#   Finds processes matching various filters (name, state, etc). Will not
#   match itself by default. The number of processes found will be tested
#   against the Warning/critical thresholds. By default, fails with a
#   CRITICAL if more than one process matches -- you must specify values
#   for -w and -c to override this.
#
#   Attempts to work on Cygwin (where ps does not have the features we
#   need) by calling Windows' tasklist.exe, but this is not well tested.#
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: english
#
# USAGE:
#   # chef-client is running
#   check-process.rb -p chef-client -W 1
#
#   # there are not too many zombies
#   check-process.rb -s Z -w 5 -c 10
#
# NOTES:
#
# LICENSE:
#   Copyright 2011 Sonian, Inc <chefs@sonian.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'English'

#
# Check Processes
#
class CheckProcess < Sensu::Plugin::Check::CLI
  option :warn_over,
         short: '-w N',
         long: '--warn-over N',
         description: 'Trigger a warning if over a number',
         proc: proc(&:to_i)

  option :crit_over,
         short: '-c N',
         long: '--critical-over N',
         description: 'Trigger a critical if over a number',
         proc: proc(&:to_i)

  option :warn_under,
         short: '-W N',
         long: '--warn-under N',
         description: 'Trigger a warning if under a number',
         proc: proc(&:to_i),
         default: 1

  option :crit_under,
         short: '-C N',
         long: '--critical-under N',
         description: 'Trigger a critial if under a number',
         proc: proc(&:to_i),
         default: 1

  option :metric,
         short: '-t METRIC',
         long: '--metric METRIC',
         description: 'Trigger a critical if there are METRIC procs',
         proc: proc(&:to_sym)

  option :match_self,
         short: '-m',
         long: '--match-self',
         description: 'Match itself',
         boolean: true,
         default: false

  option :match_parent,
         short: '-M',
         long: '--match-parent',
         description: 'Match parent process it uses ruby {process.ppid}',
         boolean: true,
         default: false

  option :cmd_pat,
         short: '-p PATTERN',
         long: '--pattern PATTERN',
         description: 'Match a command against this pattern'

  option :exclude_pat,
         short: '-x PATTERN',
         long: '--exclude-pattern PATTERN',
         description: "Don't match against a pattern to prevent false positives"

  option :file_pid,
         short: '-f PID',
         long: '--file-pid PID',
         description: 'Check against a specific PID'

  option :file_pid_crit,
         short: '-F',
         long: '--file-pid-crit',
         description: 'Trigger a critical if pid file is specified but non-existent'

  option :vsz,
         short: '-z VSZ',
         long: '--virtual-memory-size VSZ',
         description: 'Trigger on a Virtual Memory size is bigger than this',
         proc: proc(&:to_i)

  option :rss,
         short: '-r RSS',
         long: '--resident-set-size RSS',
         description: 'Trigger on a Resident Set size is bigger than this',
         proc: proc(&:to_i)

  option :cpu_utilization,
         short: '-P xx',
         long: '--cpu-utilization xx',
         description: 'Trigger on a Proportional Set Size is bigger than this',
         proc: proc(&:to_f)

  option :thcount,
         short: '-T THCOUNT',
         long: '--thread-count THCOUNT',
         description: 'Trigger on a Thread Count is bigger than this',
         proc: proc(&:to_i)

  option :state,
         short: '-s STATE',
         long: '--state STATE',
         description: 'Trigger on a specific state, example: Z for zombie',
         proc: proc { |a| a.split(',') }

  option :user,
         short: '-u USER',
         long: '--user USER',
         description: 'Trigger on a specific user',
         proc: proc { |a| a.split(',') }

  option :esec_over,
         short: '-e SECONDS',
         long: '--esec-over SECONDS',
         proc: proc(&:to_i),
         description: 'Match processes that are older than this, in SECONDS'

  option :esec_under,
         short: '-E SECONDS',
         long: '--esec-under SECONDS',
         proc: proc(&:to_i),
         description: 'Match process that are younger than this, in SECONDS'

  option :cpu_over,
         short: '-i SECONDS',
         long: '--cpu-over SECONDS',
         proc: proc(&:to_i),
         description: 'Match processes cpu time that is older than this, in SECONDS'

  option :cpu_under,
         short: '-I SECONDS',
         long: '--cpu-under SECONDS',
         proc: proc(&:to_i),
         description: 'Match processes cpu time that is younger than this, in SECONDS'

  option :encoding,
         description: 'Explicit encoding when reading process list',
         long: '--encoding ENCODING',
         default: 'ASCII-8BIT'

  # Read the pid file
  # @param path [String] the path to the pid file, including the file
  def read_pid(path)
    if File.exist?(path)
      File.read(path).strip.to_i
    elsif config[:file_pid_crit].nil?
      unknown "Could not read pid file #{path}"
    else
      critical "Could not read pid file #{path}"
    end
  end

  # read the output of a command
  # @param cmd [String] the command to read the output from
  def read_lines(cmd)
    IO.popen(cmd + ' 2>&1', external_encoding: config[:encoding]) do |child|
      child.read.split("\n")
    end
  end

  # create a hash from the output of each line of a command
  # @param line [String]
  # @param cols
  #
  def line_to_hash(line, *cols)
    Hash[cols.zip(line.strip.split(/\s+/, cols.size))]
  end

  # Is this running on cygwin
  #
  #
  def on_cygwin?
    # #YELLOW
    `ps -W 2>&1`; $CHILD_STATUS.exitstatus.zero? # rubocop:disable Semicolon
  end

  # Acquire all the proceeses on a system for further analysis
  #
  def acquire_procs
    if on_cygwin?
      read_lines('ps -aWl').drop(1).map do |line|
        # Horrible hack because cygwin's ps has no o option, every
        # format includes the STIME column (which may contain spaces),
        # and the process state (which isn't actually a column) can be
        # blank. As of revision 1.35, the format is:
        # const char *lfmt = "%c %7d %7d %7d %10u %4s %4u %8s %s\n";
        state = line.slice!(0..0)
        _stime = line.slice!(45..53)
        line_to_hash(line, :pid, :ppid, :pgid, :winpid, :tty, :uid, :etime, :command, :time).merge(state: state)
      end
    else
      read_lines('ps axwwo user,pid,vsz,rss,pcpu,nlwp,state,etime,time,command').drop(1).map do |line|
        line_to_hash(line, :user, :pid, :vsz, :rss, :cpu, :thcount, :state, :etime, :time, :command)
      end
    end
  end

  # Match to a time
  #
  def etime_to_esec(etime)
    m = /(\d+-)?(\d\d:)?(\d\d):(\d\d)/.match(etime)
    (m[1] || 0).to_i * 86_400 + (m[2] || 0).to_i * 3600 + (m[3] || 0).to_i * 60 + (m[4] || 0).to_i
  end

  # Match to a time
  #
  def cputime_to_csec(time)
    m = /(\d+-)?(\d\d:)?(\d\d):(\d\d)/.match(time)
    (m[1] || 0).to_i * 86_400 + (m[2] || 0).to_i * 3600 + (m[3] || 0).to_i * 60 + (m[4] || 0).to_i
  end

  # The main function
  #
  def run
    procs = acquire_procs

    if config[:file_pid] && (file_pid = read_pid(config[:file_pid]))
      procs.select! { |p| p[:pid].to_i == file_pid }
    end

    procs.reject! { |p| p[:pid].to_i == $PROCESS_ID } unless config[:match_self]
    procs.reject! { |p| p[:pid].to_i == Process.ppid } unless config[:match_parent]
    procs.reject! { |p| p[:command] =~ /#{config[:exclude_pat]}/ } if config[:exclude_pat]
    procs.select! { |p| p[:command] =~ /#{config[:cmd_pat]}/ } if config[:cmd_pat]
    procs.select! { |p| p[:vsz].to_f > config[:vsz] } if config[:vsz]
    procs.select! { |p| p[:rss].to_f > config[:rss] } if config[:rss]
    procs.select! { |p| p[:cpu].to_f > config[:cpu_utilization] } if config[:cpu_utilization]
    procs.select! { |p| p[:thcount].to_i > config[:thcount] } if config[:thcount]
    procs.reject! { |p| etime_to_esec(p[:etime]) >= config[:esec_under] } if config[:esec_under]
    procs.reject! { |p| etime_to_esec(p[:etime]) <= config[:esec_over] } if config[:esec_over]
    procs.reject! { |p| cputime_to_csec(p[:time]) >= config[:cpu_under] } if config[:cpu_under]
    procs.reject! { |p| cputime_to_csec(p[:time]) <= config[:cpu_over] } if config[:cpu_over]
    procs.select! { |p| config[:state].include?(p[:state]) } if config[:state]
    procs.select! { |p| config[:user].include?(p[:user]) } if config[:user]

    msg = "Found #{procs.size} matching processes"
    msg += "; cmd /#{config[:cmd_pat]}/" if config[:cmd_pat]
    msg += "; state #{config[:state].join(',')}" if config[:state]
    msg += "; user #{config[:user].join(',')}" if config[:user]
    msg += "; vsz > #{config[:vsz]}" if config[:vsz]
    msg += "; rss > #{config[:rss]}" if config[:rss]
    msg += "; cpu > #{config[:cpu_utilization]}" if config[:cpu_utilization]
    msg += "; thcount > #{config[:thcount]}" if config[:thcount]
    msg += "; esec < #{config[:esec_under]}" if config[:esec_under]
    msg += "; esec > #{config[:esec_over]}" if config[:esec_over]
    msg += "; csec < #{config[:cpu_under]}" if config[:cpu_under]
    msg += "; csec > #{config[:cpu_over]}" if config[:cpu_over]
    msg += "; pid #{config[:file_pid]}" if config[:file_pid]

    if config[:metric]
      # #YELLOW
      count = procs.map { |p| p[config[:metric]].to_i }.reduce { |a, b| a + b }
      msg += "; #{config[:metric]} == #{count}"
    else
      count = procs.size
    end

    # #YELLOW
    if !!config[:crit_under] && count < config[:crit_under] # rubocop:disable Style/DoubleNegation
      critical msg
    # #YELLOW
    elsif !!config[:crit_over] && count > config[:crit_over] # rubocop:disable Style/DoubleNegation
      critical msg
    # #YELLOW
    elsif !!config[:warn_under] && count < config[:warn_under] # rubocop:disable Style/DoubleNegation
      warning msg
    # #YELLOW
    elsif !!config[:warn_over] && count > config[:warn_over] # rubocop:disable Style/DoubleNegation
      warning msg
    else
      ok msg
    end
  end
end

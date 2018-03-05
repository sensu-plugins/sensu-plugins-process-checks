#! /usr/bin/env ruby
#
#   check-process-restart
#
# DESCRIPTION:
#   This will check if a running process requires a restart if a
#   dependent package/library has changed (i.e upgraded)
#
# OUTPUT:
#   plain text
#   Defaults: CRITICAL if 2 or more process require a restart
#             WARNING if 1 process requires a restart
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: json
#   deb: debian-goodies
#   gem: english
#
# USAGE:
#   check-process-restart.rb # Uses defaults
#   check-process-restart.rb -w 2 -c 5
#
# NOTES:
#   This will only work on Debian or Red Hat-based distributions.
#   In the case of Debian-based distributions, the debian-goodies
#   package will need to be installed.
#
#   Also make sure the user "sensu" can sudo without password
#
# LICENSE:
#   Yasser Nabi yassersaleemi@gmail.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'json'
require 'English'

# Use to see if any processes require a restart
class CheckProcessRestart < Sensu::Plugin::Check::CLI
  option :warn,
         short: '-w WARN',
         description: 'the number of processes to need restart before warn',
         default: 1

  option :crit,
         short: '-c CRIT',
         description: 'the number of processes to need restart before critical',
         default: 2

  option :args,
         short: '-a ARGS',
         description: 'arguments to pass to the checkrestart or needs-restarting tool. Quote flags like this: -a \'-p\'',
         default: ''

  # Debian command to run
  CHECK_RESTART = '/usr/sbin/checkrestart'.freeze

  # Red Hat command to run
  NEEDS_RESTARTING = '/usr/bin/needs-restarting'.freeze

  # Set path for the checkrestart script
  #
  def initialize
    super
  end

  # Check if we can run checkrestart script
  # @return [Boolean]
  #
  def checkrestart?
    File.exist?('/etc/debian_version') && File.exist?(CHECK_RESTART)
  end

  # Check if we can run needs-restarting script
  # @return [Boolean]
  #
  def needs_restarting?
    File.exist?(NEEDS_RESTARTING)
  end

  # Run checkrestart and parse process(es) and pid(s)
  # @return [Hash]
  def run_checkrestart
    checkrestart_hash = { found: '', pids: [] }

    out = `sudo #{CHECK_RESTART} #{config[:args]} 2>&1`
    if $CHILD_STATUS.to_i.nonzero?
      checkrestart_hash[:found] = "Failed to run checkrestart: #{out}"
    else
      out.lines do |l|
        m = /^Found\s(\d+)/.match(l)
        if m
          checkrestart_hash[:found] = m[1]
        end

        m = /^\s+(\d+)\s+([ \w\/\-\.]+)$/.match(l)
        if m
          checkrestart_hash[:pids] << { m[1] => m[2] }
        end
      end
    end
    checkrestart_hash
  end

  # Run needs-restarting and parse process(es) and pid(s)
  # @return [Hash]
  def run_needs_restarting
    needs_restarting_hash = { found: '', pids: [] }

    out = `sudo #{NEEDS_RESTARTING} #{config[:args]} 2>&1`
    if $CHILD_STATUS.to_i.nonzero?
      needs_restarting_hash[:found] = "Failed to run needs-restarting: #{out}"
    else
      needs_restarting_hash[:found] = `sudo #{NEEDS_RESTARTING} #{config[:args]} | wc -l | tr -d "\n"`

      out.lines do |l|
        m = /(\d+)\s:\s(.*)$/.match(l)

        if m
          needs_restarting_hash[:pids] << { m[1] => m[2] }
        end
      end
    end
    needs_restarting_hash
  end

  # Main run method for the check
  #
  def run
    if checkrestart?
      checkrestart_out = run_checkrestart

      if /^Failed/ =~ checkrestart_out[:found]
        unknown checkrestart_out[:found]
      end

      message JSON.generate(checkrestart_out)
      found = checkrestart_out[:found].to_i

      warning if found >= config[:warn].to_i && found < config[:crit].to_i
      critical if found >= config[:crit].to_i
      ok
    elsif needs_restarting?
      needs_restarting_out = run_needs_restarting

      if /^Failed/ =~ needs_restarting_out[:found]
        unknown needs_restarting_out[:found]
      end

      message JSON.generate(needs_restarting_out)
      found = needs_restarting_out[:found].to_i

      warning if found >= config[:warn].to_i && found < config[:crit].to_i
      critical if found >= config[:crit].to_i
      ok
    else
      unknown "Can't seem to find either checkrestart or needs-restarting. For checkrestart, you will need to install the debian-goodies package."
    end
  end
end

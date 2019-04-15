#! /usr/bin/env ruby
#
# metrics-ipcs
#
# DESCRIPTION:
#  metrics-ipcs get metrics from ipcs
#
# OUTPUT:
#   metric-data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#
# USAGE:
#
#
# NOTES:
#
# LICENSE:
#   Zubov Yuri <yury.zubau@gmail.com> sponsored by Actility, https://www.actility.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'open3'
require 'socket'

class MetricsIPCS < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.ipcs"

  def run_ipcs
    stdout, result = Open3.capture2('ipcs -u')
    unknown 'Unable to get ipcs' unless result.success?
    stdout
  end

  def run
    ipcs_status = run_ipcs

    found = false
    index = -1
    key = nil
    ipcs_status.each_line do |line|
      next unless line.match(/[[:space:]]*------/) ... (line == "\n")
      if line.strip == ''
        index = -1
      else
        index += 1
      end
      if index.zero? || index < 0
        key = line.tr("-\n", '').strip.tr(' ', '-').downcase
      else
        result = line.match(/[[:space:]]*(?<name>[a-zA-Z ]*).*(?<value>\d+)/)
        output "#{config[:scheme]}.#{key}.#{result[:name].strip.tr(' ', '-')}", result[:value].strip
      end
      found = true
    end
    if found
      ok
    else
      critical('Not found')
    end
  end
end

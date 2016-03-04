## Sensu-Plugins-process-checks

[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-process-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-process-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-process-checks.svg)](http://badge.fury.io/rb/sensu-plugins-process-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-process-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-process-checks)

## Functionality

**check-processs** and **check-process-restart**  will check processes on a system and alert if specific conditions exist based upon a set of filters that each has implemented.

**check-cmd** will run a specific user designated command and parse the output with a regex or check for a specific status code.  If either of these conditions is not what is expected it will alert.

## Files
 * bin/check-cmd.rb
 * bin/check-process-restart.rb
 * bin/check-process.rb
 * bin/check-threads-count.rb
 * bin/metrics-process-status.rb
 * bin/metrics-processes-threads-count.rb
 * bin/metrics-process-uptime.sh

## Usage

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes

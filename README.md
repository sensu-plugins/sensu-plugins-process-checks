## Sensu-Plugins-process-checks

[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-process-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-process-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-process-checks.svg)](http://badge.fury.io/rb/sensu-plugins-process-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-process-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-process-checks)
[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-process-checks)

## Sensu Asset  
  The Sensu assets packaged from this repository are built against the Sensu ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator or handler), make sure you include the corresponding Sensu ruby runtime asset in the list of assets needed by the resource.  The current ruby-runtime assets can be found [here](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the [Bonsai Asset Index](bonsai.sensu.io).

## Functionality

**check-processs** and **check-process-restart**  will check processes on a system and alert if specific conditions exist based upon a set of filters that each has implemented.

**check-cmd** will run a specific user designated command and parse the output with a regex or check for a specific status code.  If either of these conditions is not what is expected it will alert.

## Files
 * bin/check-cmd.rb
 * bin/check-process-restart.rb
 * bin/check-process.rb
 * bin/check-threads-count.rb
 * bin/metrics-per-process.py
 * bin/metrics-per-process.rb
 * bin/metrics-process-status.rb
 * bin/metrics-process-uptime.rb
 * bin/metrics-process-uptime.sh
 * bin/metrics-processes-threads-count.rb

## Usage

Check if an arbitrary process seems to be running or not. Our arbitrary process in this example is called `gutrot`.
Usage of `check-process.rb` would look something similar to the following:

    $ /opt/sensu/embedded/bin/ruby /opt/sensu/embedded/bin/check-process.rb -p gutrot
    CheckProcess OK: Found 3 matching processes; cmd /gutrot/

The `-p` argument is for a pattern to match against the list of running processes reported by `ps`.

Example configuration at `/etc/sensu/conf.d/check_gutrot_running.json`:

    {
      "checks": {
        "check_gutrot_running": {
          "command": "check-process.rb -p gutrot",
          "standalone": true,
          "interval": 60,
          "handlers": ["default"]
        }
      }
    }

The check is named `check_gutrot_running` and it runs `check-process.rb -p gutrot` every `60` seconds (interval)
then lets the `default` handler handle the result.

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

Quick install after following the steps above:

    $ sensu-install process-checks

The checks will be installed at:

    /opt/sensu/embedded/bin/

## Notes

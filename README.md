## Sensu-Plugins-Processes

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-processes.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-processes)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-processes.svg)](http://badge.fury.io/rb/sensu-plugins-processes)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-processes/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-processes)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-processes/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-processes)

## Functionality

*check-processs* and *check-process-restart*  will check processes on a system and alert if specific conditions exist based upon a set of filters that each has implemented.

*check-cmd* will run a specific user designated command and parse the output with a regex or check for a specific status code.  If either of these conditions is not what is expected it will alert.

## Files
 * bin/check-cmd.rb
 * bin/check-process-restart.rb
 * bin/check-process.rb

## Installation


Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install <gem> -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

`gem install sensu-plugins-processes`

Add *sensu-plugins-processes* to your Gemfile, manifest, cookbook, etc

## Notes

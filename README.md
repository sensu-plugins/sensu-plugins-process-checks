[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-process-checks.svg?branch=master)][1]
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-process-checks.svg)][2]
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks/badges/gpa.svg)][3]
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks/badges/coverage.svg)][4]
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-process-checks.svg)][5]

## Functionality

**check-processs** and **check-process-restart**  will check processes on a system and alert if specific conditions exist based upon a set of filters that each has implemented.

**check-cmd** will run a specific user designated command and parse the output with a regex or check for a specific status code.  If either of these conditions is not what is expected it will alert.

## Files
 * bin/check-cmd.rb
 * bin/check-process-restart.rb
 * bin/check-process.rb
 * bin/check-process.sh
 * bin/metrics-process-status

## Usage

#### Rubygems

`gem install sensu-plugins-process-checks`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-process-checks' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-process-checks' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

## Notes


[1]:[https://travis-ci.org/sensu-plugins/sensu-plugins-process-checks]
[2]:[http://badge.fury.io/rb/sensu-plugins-process-checks]
[3]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks]
[4]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks]
[5]:[https://gemnasium.com/sensu-plugins/sensu-plugins-process-checks]

#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Added
- check-process.rb: added `-R` to allow checking for processes whose RSS exceeds some value

## [2.3.0] - 2017-05-29
### Changed
- metrics-per-process.py: Use memory_info() in psutil versions greater than 4.0.0, as memory_info_ex() was deprecated.

## [2.2.0] - 2017-05-28
### Changed
- metrics-per-process.py: Fallback to importing Counter from backport_collections for Python 2.6 support.

## [2.1.0] - 2017-05-25
### Added
- metrics-per-process.rb: Binstub for metrics-per-process.py
- metrics-process-uptime.rb: Binstub for metrics-process-uptime.sh

## [2.0.0] 2017-05-18
### Breaking Changes
- check-process.rb: renamed `--propotional-set-size` to `--cpu-utilization` as that's really what it was. (@majormoses)
- check-process.rb: Flip the meaning of `-z`, `-r`, `-P` and `-T` to match what the help messages say they do. (@maoe)

### Changed
- check-process.rb: Added `-F` option to trigger a critical if pid file is specified but non-existent. (@swibowo)

### Added
- check-process-restart.rb: Allow additional arguments to be passed to the underlying tool using `-a`. (@tomduckering)

## [1.0.0] - 2016-06-21
### Fixed
- metrics-per-process.py: avoid false alerts by adding exception handling for `OSError` errors
- check-process.rb: avoid 'invalid byte sequence' messages by adding configurable encoding which defaults to `ASCII-8BIT`

### Added
- check-process-restart.rb: added support for Red Hat "needs-restarting" script

### Changed
- Updated Rubocop to 0.40, applied auto-correct
- Remove Ruby 1.9.3 support; add Ruby 2.3.0 support to test matrix


## [0.0.6] - 2015-08-24
### Fixed
- require 'socket' in metrics-processes-threads-count

## [0.0.5] - 2015-07-14
### Fixed
- include hostname in default scheme in metrics-processes-threads-count

### Changed
- rename process-uptime metrics.sh -> metrics-process-uptime.sh

## [0.1.0] - 2015-08-11
### Added
- Add metrics-per-process.py plugin (require python psutil module)

## [0.0.4] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.3] - [2015-07-13]
### Fixed
- issue #9: variable type conversion to_i in check-process-restart

### Changed
- updated documentation links in README and CONTRIBUTING
- removed unused rake tasks from Rakefile
- puts deps in alpha order in Rakefile
- puts deps in order in Gemspec

## [0.0.2] - 2015-06-03
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - [2015-05-01]
### Added
- initial stable release

## 0.0.1.alpha.6
### Added
- add chef provisioner to Vagrantfile
- add metadata to gemspec

### Fixed
- fix rubocop errors

## 0.0.1.alpha.5
### Added
- add new check for process uptime metrics

## 0.0.1.alpha.4
### Changed
- convert scrips to sys-proctable gem for platform independence

## 0.0.1-alpha.3
### Added
- add proc-status-metrics

### Changed
- change proc-status-metrics to process-status-metrics

## 0.0.1-alpha.2
### Changed
- bump Vagrant to Chef 6.6
- update LICENSE and gemspec authors
- update README

### Added
- add required Ruby version *>= 1.9.3*
- add test/spec_help.rb

## 0.1.0-alpha.1
- baseline release identical to **sensu-community-plugins** repo

### Changed
- changed *check-procs* to *check-process* to better reflect its use
- pinned dependencies

### Added
- basic yard coverage
- built against 1.9.3, 2.0, 2.1
- cryptographically signed

[unreleased]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.3.0...HEAD
[2.3.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.2.0...2.3.0
[2.2.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/0.0.6...1.0.0
[0.0.6]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/0.0.1...0.0.2

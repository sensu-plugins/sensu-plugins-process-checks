# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)


## [Unreleased]

### Security
- updated yard dependency to `~> 0.9.11` per: https://nvd.nist.gov/vuln/detail/CVE-2017-17042 (@majormoses)

## [3.0.1] - 2018-03-17
### Fixed
- check-process.rb: fixed an issue introduced in #61 (@majormoses)

## [3.0.0] - 2018-03-17
### Security
- updated rubocop dependency to `~> 0.51.0` per: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8418. (@majormoses)

### Breaking Changes
- removed ruby `< 2.1` support (@majormoses)

### Changed
- appeased the cops (@majormoses)

## [2.7.0] - 2018-01-06
### Changed
- metrics-per-processes.py: Add option to find processes by username (@rthouvenin)

## [2.6.0] - 2017-12-05
### Changed
- loosen dependency of `sys-proctable` (@majormoses)

### Removed
- check-threads-count.rb, metrics-processes-threads-count.rb: checks on `sys-proctable` versions as we now require new enough versions. (@majormoses)

## [2.5.0] - 2017-10-04
### Added
- metric-per-processes.py: Add metrics filter (@rthouvenin)

### Changed
- updated changelog guidelines (@majormoses)

### Fixed
- spelling in PR template (@majormoses)

## [2.4.0] - 2017-07-18
### Added
- ruby 2.4 testing (@majormoses)
- metric-processes-threads-count.rb: count processes by status (for Linux machines only) (@alcasim)

### Changed
- PR template fixes (@majormoses)

### Fixed
- misc changelog fixup (@majormoses)
- fixed `rake check_binstubs` by requiging `English`

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

## [0.1.0] - 2015-08-11
### Added
- Add metrics-per-process.py plugin (require python psutil module)

## [0.0.6] - 2015-08-24
### Fixed
- require 'socket' in metrics-processes-threads-count

## [0.0.5] - 2015-07-14
### Fixed
- include hostname in default scheme in metrics-processes-threads-count

### Changed
- rename process-uptime metrics.sh -> metrics-process-uptime.sh

## [0.0.4] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.3] - 2015-07-13
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

## [0.0.1] - 2015-05-01
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

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/3.0.1...HEAD
[3.0.1]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.7.0...3.0.0
[2.7.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.6.0...2.7.0
[2.6.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.5.0...2.6.0
[2.5.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.4.0...2.5.0
[2.4.0]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/2.3.0...2.4.0
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
[0.0.1]: https://github.com/sensu-plugins/sensu-plugins-process-checks/compare/4fd88a85f31d52c0f7145807365c911ea7f935c1...0.0.1

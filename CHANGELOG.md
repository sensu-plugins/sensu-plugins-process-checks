#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## Unreleased

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

## [0.0.1] - [2015-05-01]

### Added
- initial stable release

## [0.0.1.alpha.6]

### Added
- add chef provisioner to Vagrantfile
- add metadata to gemspec

### Fixed
- fix rubocop errors

## [0.0.1.alpha.5]

### Added
- add new check for process uptime metrics

## [0.0.1.alpha.4]

### Changed
- convert scrips to sys-proctable gem for platform independence

## [0.0.1-alpha.3]

### Added
- add proc-status-metrics

### Changed
- change proc-status-metrics to process-status-metrics

## [0.0.1-alpha.2]

### Changed
- bump Vagrant to Chef 6.6
- update LICENSE and gemspec authors
- update README

### Added
- add required Ruby version *>= 1.9.3*
- add test/spec_help.rb

## [0.1.0-alpha.1]

- baseline release identical to **sensu-community-plugins** repo

### Changed
- changed *check-procs* to *check-process* to better reflect its use
- pinned dependencies

### Added
- basic yard coverage
- built against 1.9.3, 2.0, 2.1
- cryptographically signed

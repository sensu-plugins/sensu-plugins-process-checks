#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## Unreleased][unreleased]

## [0.0.2] - 2015-06-03

### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-05-01

### Added
- initial release

#### 0.0.1.alpha.6

* add chef provisioner to Vagrantfile
* fix rubocop errors
* add metadata to gemspec

#### 0.0.1.alpha.5

* add new check for process uptime metrics

#### 0.0.1.alpha.4

* convert scrips to sys-proctable gem for platform independence

#### 0.0.1-alpha.3

* add proc-status-metrics
* change proc-status-metrics to process-status-metrics

#### 0.0.1-alpha.2

* bump Vagrant to Chef 6.6
* update LICENSE and gemspec authors
* update README
* add required Ruby version *>= 1.9.3*
* add test/spec_help.rb

#### 0.1.0-alpha.1

* baseline release identical to **sensu-community-plugins** repo
* changed *check-procs* to *check-process* to better reflect its use
* basic yard coverage
* pinned dependencies
* built against 1.9.3, 2.0, 2.1
* cryptographically signed

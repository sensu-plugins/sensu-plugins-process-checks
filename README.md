[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-process-checks)
[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-process-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-process-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-process-checks.svg)](http://badge.fury.io/rb/sensu-plugins-process-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-process-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-process-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-process-checks)

## Sensu Plugins Process Checks Plugin

- [Overview](#overview)
- [Files](#files)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
  - [Sensu Go](#sensu-go)
    - [Asset registration](#asset-registration)
    - [Asset definition](#asset-definition)
    - [Check definition](#check-definition)
  - [Sensu Core](#sensu-core)
    - [Check definition](#check-definition)
- [Installation from source](#installation-from-source)
- [Additional notes](#additional-notes)
- [Contributing](#contributing)

### Overview

This plugin provides native instrumentation for monitoring log files or system logs via journald for regular expressions and a Sensu handler for logging Sensu events to log files.

### Files
 * bin/check-cmd.rb
 * bin/check-process-restart.rb
 * bin/check-process.rb
 * bin/check-threads-count.rb
 * bin/metrics-ipcs.rb
 * bin/metrics-per-process.rb
 * bin/metrics-process-status.rb
 * bin/metrics-process-uptime.rb
 * bin/metrics-processes-threads-count.rb

**check-cmd**
Generic check that raises an error if exit code of command is not N. Runs a specific user-designated command and parses the output with a regex or checks for a specific status code. If either of these conditions is not a expected, the check will alert.

**check-process-restart**
Checks if a running process requires a restart if a dependent package/library has changed (e.g. is upgraded).

**check-process**
Checks processes on a system and alerts if specific conditions exist based on the set of filters implemented. Finds processes that match various filters (name, state, etc). Will not match itself by default. The number of processes found will be tested against the Warning/Critical thresholds. By default, fails with CRITICAL if more than one process matches (you must specify values for -w and -c to override this).

**check-threads-count**
Counts the number of threads running on the system and alerts if that number is greater than the warning or critical values.

**metrics-ipcs**
Gets metrics from IPCS.

**metrics-per-process**
Gets metrics for a specific process.

**metrics-process-status**
Returns selected memory metrics from /proc/[PID]/status for all processes owned by a user AND/OR matching the provided process name substring.

**metrics-process-uptime**
Gets uptime metrics for a process if the process name is specified or looks for the pid file if the path to the pid file is specified.

**metrics-processes-threads-count**
Counts the number of processes running on the system (and optionally, the number of running threads) and outputs it in metric format. Can alternatively count the number of processes/threads that match a certain substring.

## Usage examples

### Help

**check-process.rb**
```
Usage: check-process.rb (options)
    -p, --pattern PATTERN            Match a command against this pattern
    -i, --cpu-over SECONDS           Match processes cpu time that is older than this, in SECONDS
    -I, --cpu-under SECONDS          Match processes cpu time that is younger than this, in SECONDS
    -P, --cpu-utilization xx         Trigger on a Proportional Set Size is bigger than this
    -c, --critical-over N            Trigger a critical if over a number
    -C, --critical-under N           Trigger a critial if under a number
        --encoding ENCODING          Explicit encoding when reading process list
    -e, --esec-over SECONDS          Match processes that are older than this, in SECONDS
    -E, --esec-under SECONDS         Match process that are younger than this, in SECONDS
    -x, --exclude-pattern PATTERN    Don't match against a pattern to prevent false positives
    -f, --file-pid PID               Check against a specific PID
    -F, --file-pid-crit              Trigger a critical if pid file is specified but non-existent
    -M, --match-parent               Match parent process it uses ruby {process.ppid}
    -m, --match-self                 Match itself
    -t, --metric METRIC              Trigger a critical if there are METRIC procs
    -r, --resident-set-size RSS      Trigger on a Resident Set size is bigger than this
    -s, --state STATE                Trigger on a specific state, example: Z for zombie
    -T, --thread-count THCOUNT       Trigger on a Thread Count is bigger than this
    -u, --user USER                  Trigger on a specific user
    -z, --virtual-memory-size VSZ    Trigger on a Virtual Memory size is bigger than this
    -w, --warn-over N                Trigger a warning if over a number
    -W, --warn-under N               Trigger a warning if under a number
```

**metrics-process-status.rb**
```
Usage: metrics-process-status.rb (options)
    -m, --metrics METRICS            Memory metrics to collect from /proc/[PID]/status, comma-separated
    -p, --process-name PROCESSNAME   Process name substring to match against, not a regex.
        --scheme SCHEME              Metric naming scheme
    -u, --user USER                  Query processes owned by a user
```

## Configuration
### Sensu Go
#### Asset registration

Assets are the best way to make use of this plugin. If you're not using an asset, please consider doing so! If you're using sensuctl 5.13 or later, you can use the following command to add the asset: 

`sensuctl asset add sensu-plugins/sensu-plugins-process-checks`

If you're using an earlier version of sensuctl, you can download the asset definition from [this project's Bonsai asset index page](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-process-checks).

#### Asset definition

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-plugins-process-checks
spec:
  url: https://assets.bonsai.sensu.io/d582eeb357ca2c483cf1dc290640baca8dcd66f5/sensu-plugins-process-checks_4.1.0_centos_linux_amd64.tar.gz
  sha512: 649e15dc32e38f5d35af1c50ec2e473e8355029de2a42baf9ef93ee7def57aee8829b197ce9bdf19271739056677d020eeeb8db3fcf533dcc2999358af500102
```

#### Check definition

```yaml
---
type: CheckConfig
spec:
  command: "check-process.rb"
  handlers: []
  high_flap_threshold: 0
  interval: 10
  low_flap_threshold: 0
  publish: true
  runtime_assets:
  - sensu-plugins/sensu-plugins-process-checks
  - sensu/sensu-ruby-runtime
  subscriptions:
  - linux
```

### Sensu Core

#### Check definition

Check if an arbitrary process seems to be running or not. Our arbitrary process in this example is called `gutrot`.
Usage of `check-process.rb` would look similar to:

```shell
$ /opt/sensu/embedded/bin/ruby /opt/sensu/embedded/bin/check-process.rb -p gutrot
CheckProcess OK: Found 3 matching processes; cmd /gutrot/
```

The `-p` argument is for a pattern to match against the list of running processes reported by `ps`.

Example configuration at `/etc/sensu/conf.d/check_gutrot_running.json`:

```json
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
```

The check is named `check_gutrot_running` and it runs `check-process.rb -p gutrot` every `60` seconds (interval)
then lets the `default` handler handle the result.

## Installation from source

### Sensu Go

See the instructions above for [asset registration](#asset-registration).

### Sensu Core

Install and setup plugins on [Sensu Core](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/).

## Additional notes

### Sensu Go Ruby Runtime Assets

The Sensu assets packaged from this repository are built against the Sensu Ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator, or handler), make sure to include the corresponding [Sensu Ruby Runtime Asset](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the list of assets needed by the resource.

## Contributing

See [CONTRIBUTING.md](https://github.com/sensu-plugins/sensu-plugins-process-checks/blob/master/CONTRIBUTING.md) for information about contributing to this plugin.


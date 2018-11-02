lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'
require_relative 'lib/sensu-plugins-process-checks'

Gem::Specification.new do |s| # rubocop: disable Metrics/BlockLength
  s.authors                = ['Sensu-Plugins and contributors']

  s.date                   = Date.today.to_s
  s.description            = 'This plugin provides native process instrumentation
                              for monitoring and metrics collection, including:
                              process status, uptime, thread count, and others'
  s.email                  = '<sensu-users@googlegroups.com>'
  s.executables            = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  s.files                  = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md CHANGELOG.md]
  s.homepage               = 'https://github.com/sensu-plugins/sensu-plugins-process-checks'
  s.license                = 'MIT'
  s.metadata               = { 'maintainer'         => '@rmc3',
                               'development_status' => 'active',
                               'production_status'  => 'unstable - testing recommended',
                               'release_draft'      => 'false',
                               'release_prerelease' => 'false' }
  s.name                   = 'sensu-plugins-process-checks'
  s.platform               = Gem::Platform::RUBY
  s.post_install_message   = 'You can use the embedded Ruby by setting EMBEDDED_RUBY=true in /etc/default/sensu'
  s.require_paths          = ['lib']
  s.required_ruby_version  = '>= 2.1.0'

  s.summary                = 'Sensu plugins for checking running processes'
  s.test_files             = s.files.grep(%r{^(test|spec|features)/})
  s.version                = SensuPluginsProcessChecks::Version::VER_STRING

  s.add_runtime_dependency 'english', '0.6.3'
  s.add_runtime_dependency 'sensu-plugin', '~> 1.2'
  s.add_runtime_dependency 'sys-proctable', '~> 0.9.8'

  s.add_development_dependency 'bundler',                   '~> 1.7'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
  s.add_development_dependency 'github-markup',             '~> 3.0'
  s.add_development_dependency 'pry',                       '~> 0.10'
  s.add_development_dependency 'rake',                      '~> 10.0'
  s.add_development_dependency 'redcarpet',                 '~> 3.2'
  s.add_development_dependency 'rspec',                     '~> 3.7'
  s.add_development_dependency 'rspec-mocks',               '~> 3.7'
  s.add_development_dependency 'rubocop',                   '~> 0.51.0'
  s.add_development_dependency 'yard',                      '~> 0.9.11'
end

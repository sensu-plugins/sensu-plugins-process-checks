#!/usr/bin/env ruby
#
# metric-processes-threads-count_spec
#
# DESCRIPTION:
#   Tests for metric-processes-threads-count_spec
#
# OUTPUT:
#
# PLATFORMS:
#
# DEPENDENCIES:
#
# USAGE:
#   bundle install
#   rake spec
#
# NOTES:
#   This test suite mocks up a process table to be returned by Sys::ProcTable.ps()
#
# LICENSE:
#   Copyright 2015 Contegix, LLC.
#   Released under the same terms as Sensu (the MIT license); see LICENSE for details.
#
require_relative './plugin_stub.rb'
require_relative './spec_helper.rb'
require_relative '../bin/metrics-processes-threads-count.rb'

RSpec.configure do |c|
  c.before { allow($stdout).to receive(:puts) }
  c.before { allow($stderr).to receive(:puts) }
end

describe ProcessesThreadsCount, 'count_threads' do
  it 'should be able to count threads from ProcTable structs with :nlwp fields' do
    nlwp_entry = Struct.new(:nlwp)
    table = [nlwp_entry.new(3), nlwp_entry.new(1), nlwp_entry.new(6)]
    ptcount = ProcessesThreadsCount.new
    expect(ptcount.count_threads(table)).to eq(10)
  end

  it 'should be able to count threads from ProcTable structs with :thread_count fields' do
    tc_entry = Struct.new(:thread_count)
    table = [tc_entry.new(3), tc_entry.new(1), tc_entry.new(6)]
    ptcount = ProcessesThreadsCount.new
    expect(ptcount.count_threads(table)).to eq(10)
  end
end

describe ThreadsCount, 'run' do
  it 'returns unknown if check_proctable_version returns false and config[:threads] is true' do
    nlwp_entry = Struct.new(:thread_count)
    table = [nlwp_entry.new(3), nlwp_entry.new(1), nlwp_entry.new(6)]
    allow(Sys::ProcTable).to receive(:ps).and_return(table)
    ptcount = ProcessesThreadsCount.new
    ptcount.config[:threads] = true
    allow(ptcount).to receive(:count_threads).and_return(0)
    allow(ptcount).to receive(:check_proctable_version).and_return(false)
    expect(ptcount).to receive(:unknown)
    expect(-> { ptcount.run }).to raise_error SystemExit
  end

  it 'does not return unknown if check_proctable_version returns false and config[:threads] is false' do
    nlwp_entry = Struct.new(:thread_count)
    table = [nlwp_entry.new(3), nlwp_entry.new(1), nlwp_entry.new(6)]
    allow(Sys::ProcTable).to receive(:ps).and_return(table)
    ptcount = ProcessesThreadsCount.new
    ptcount.config[:threads] = false
    allow(ptcount).to receive(:count_threads).and_return(0)
    allow(ptcount).to receive(:check_proctable_version).and_return(false)
    expect(ptcount).to_not receive(:unknown)
    expect(-> { ptcount.run }).to raise_error SystemExit
  end

  it 'outputs process and threads count metrics when config[:threads] is true' do
    nlwp_entry = Struct.new(:thread_count)
    table = [nlwp_entry.new(3), nlwp_entry.new(1), nlwp_entry.new(6)]
    allow(Sys::ProcTable).to receive(:ps).and_return(table)
    ptcount = ProcessesThreadsCount.new
    ptcount.config[:threads] = true
    allow(ptcount).to receive(:output)
    expect(ptcount).to receive(:output).with(match('process_count 3 '))
    expect(ptcount).to receive(:output).with(match('thread_count 10 '))
    expect(-> { ptcount.run }).to raise_error SystemExit
  end

  it 'does not output threads count metrics when config[:threads] is false' do
    nlwp_entry = Struct.new(:thread_count)
    table = [nlwp_entry.new(3), nlwp_entry.new(1), nlwp_entry.new(6)]
    allow(Sys::ProcTable).to receive(:ps).and_return(table)
    ptcount = ProcessesThreadsCount.new
    allow(ptcount).to receive(:output)
    expect(ptcount).to receive(:output).with(match('process_count 3 '))
    expect(ptcount).to_not receive(:output).with(match('threads_count 10 '))
    expect(-> { ptcount.run }).to raise_error SystemExit
  end
end

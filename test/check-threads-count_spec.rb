#!/usr/bin/env ruby
#

require_relative './plugin_stub.rb'
require_relative './spec_helper.rb'
require_relative '../bin/check-threads-count.rb'

RSpec.configure do |c|
  c.before { allow($stdout).to receive(:puts) }
  c.before { allow($stderr).to receive(:puts) }
end

describe ThreadsCount, 'count_threads' do
  # Here, we mock Sys::ProcTable.ps() to return an array of structs with only the property this class cares about.
  #
  it 'should be able to count threads from ProcTable structs with :nlwp fields' do
    NLWPEntry = Struct.new(:nlwp)
    table = [NLWPEntry.new(3), NLWPEntry.new(1), NLWPEntry.new(6)]
    allow(Sys::ProcTable).to receive(:ps).and_return(table)
    threadscount = ThreadsCount.new
    expect(threadscount.count_threads).to eq(10)
  end

  it 'should be able to count threads from ProcTable structs with :thread_count fields' do
    TCEntry = Struct.new(:thread_count)
    table = [TCEntry.new(3), TCEntry.new(1), TCEntry.new(6)]
    allow(Sys::ProcTable).to receive(:ps).and_return(table)
    threadscount = ThreadsCount.new
    expect(threadscount.count_threads).to eq(10)
  end

end

describe ThreadsCount, 'run' do

  it 'returns unknown if check_proctable_version returns false' do
    threadscount = ThreadsCount.new
    allow(threadscount).to receive(:count_threads).and_return(0)
    allow(threadscount).to receive(:check_proctable_version) { false }
    expect(threadscount).to receive(:unknown)
    threadscount.run
  end

  it 'returns critical if count_threads returns more than the critical threshold' do
    threadscount = ThreadsCount.new
    threadscount.config[:warn] = 10
    threadscount.config[:crit] = 15
    allow(threadscount).to receive(:count_threads).and_return(20)
    expect(threadscount).to receive(:critical)
    expect(-> { threadscount.run }).to raise_error SystemExit
  end

  it 'returns warning if count_threads returns more than the warning threshold' do
    threadscount = ThreadsCount.new
    threadscount.config[:warn] = 10
    threadscount.config[:crit] = 30
    allow(threadscount).to receive(:count_threads).and_return(20)
    expect(threadscount).to receive(:warning)
    expect(-> { threadscount.run }).to raise_error SystemExit
  end

  it 'returns ok if count_threads returns less than the critical or warning thresholds' do
    threadscount = ThreadsCount.new
    threadscount.config[:warn] = 10
    threadscount.config[:crit] = 20
    allow(threadscount).to receive(:count_threads).and_return(5)
    expect(threadscount).to receive(:ok)
    threadscount.run
  end

end

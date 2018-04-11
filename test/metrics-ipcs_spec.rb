require_relative './spec_helper'
require_relative '../bin/metrics-ipcs'
require_relative './fixtures/metrics-ips_fixture'

describe 'MetricsIPCS' do
  before do
    MetricsIPCS.class_variable_set(:@@autorun, false)
  end

  describe 'with positive answer' do
    before do
      @default_parameters = '--scheme=test'
      @metrics = MetricsIPCS.new(@default_parameters.split(' '))
      allow(@metrics).to receive(:run_ipcs).and_return(ipcs_answer)
      allow(@metrics).to receive(:ok)
      allow(@metrics).to receive(:critical)
    end

    describe '#run' do
      it 'tests that a check are ok' do
        @output_result = {}
        allow(@metrics).to receive(:output).and_wrap_original do |_m, *args|
          @output_result[args[0]] = args[1]
        end
        @metrics.run
        expect(@output_result['test.shared-memory-status.pages-resident']).to eq '5'
        expect(@output_result['test.shared-memory-status.pages-allocated']).to eq '3'
      end
    end
  end
end

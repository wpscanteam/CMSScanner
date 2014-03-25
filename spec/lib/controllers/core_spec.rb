require 'spec_helper'

describe CMSScanner::Controller::Core do

  subject(:core)   { described_class.new }
  let(:target_url) { 'http://example.com/' }
  before           { described_class.parsed_options = { url: target_url }  }

  its(:cli_options) { should_not be_empty }
  its(:cli_options) { should be_a Array }

  describe '#before_scan' do
    xit
  end

  describe '#run' do
    it 'calls the formatter with the correct parameters' do
      core.formatter.should_receive(:output)
        .with('core/started', hash_including(:start_memory, :start_time, :verbose, url: target_url))

      core.run
    end
  end

  describe '#after_scan' do
    let(:keys) { [:verbose, :start_time, :stop_time, :start_memory, :elapsed, :used_memory] }

    it 'calles the formatter with the correct parameters' do
      # Call the #run once to ensure that @start_time & @start_memory are set
      core.should_receive(:output).with('started', url: target_url)
      core.run

      RSpec::Mocks.proxy_for(core).reset # Must reset due to the above statements

      core.formatter.should_receive(:output)
        .with('core/finished', hash_including(*keys))

      core.after_scan
    end
  end

end

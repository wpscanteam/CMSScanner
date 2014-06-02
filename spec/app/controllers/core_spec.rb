require 'spec_helper'

describe CMSScanner::Controller::Core do

  subject(:core)       { described_class.new }
  before               { described_class.parsed_options = parsed_options  }
  let(:target_url)     { 'http://example.com/' }
  let(:parsed_options) { { url: target_url } }

  its(:cli_options) { should_not be_empty }
  its(:cli_options) { should be_a Array }

  describe '#before_scan' do
    it 'raise an error when the site is down' do
      stub_request(:get, target_url).to_return(status: 0)

      expect { core.before_scan }
        .to raise_error("The url supplied '#{target_url}' seems to be down")
    end

    it 'raises an error when the site redirects' do
      redirection = 'http://somewhere.com'

      stub_request(:get, target_url).to_return(status: 301, headers: { location: redirection })
      stub_request(:get, redirection).to_return(status: 200)

      expect { core.before_scan }
        .to raise_error("The url supplied redirects to #{redirection}")
    end

    context 'when basic authentication is detected' do
      before { stub_request(:get, target_url).to_return(status: 401) }

      context 'when no credentials are supplied' do
        it 'raises an error' do
          expect { core.before_scan }
            .to raise_error('Basic authentication is required, please provide it with --basic-auth')
        end
      end

      context 'when credentials are provided' do
        let(:parsed_options) { { url: target_url, basic_auth: 'user:pass' } }

        it 'does not raise any error' do
          expect { core.before_scan }.to_not raise_error
        end
      end
    end
  end

  describe '#run' do
    it 'calls the formatter with the correct parameters' do
      expect(core.formatter).to receive(:output)
        .with('started',
              hash_including(:start_memory, :start_time, :verbose, url: target_url),
              'core')

      core.run
    end
  end

  describe '#after_scan' do
    let(:keys) { [:verbose, :start_time, :stop_time, :start_memory, :elapsed, :used_memory] }

    it 'calles the formatter with the correct parameters' do
      # Call the #run once to ensure that @start_time & @start_memory are set
      expect(core).to receive(:output).with('started', url: target_url)
      core.run

      RSpec::Mocks.space.proxy_for(core).reset # Must reset due to the above statements

      expect(core.formatter).to receive(:output)
        .with('finished', hash_including(*keys), 'core')

      core.after_scan
    end
  end

end

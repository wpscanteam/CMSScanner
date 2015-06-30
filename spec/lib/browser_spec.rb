require 'spec_helper'

describe CMSScanner::Browser do
  it_behaves_like described_class::Actions

  subject(:browser) { described_class.instance(options) }
  before            { described_class.reset }
  let(:options)     { {} }
  let(:default) do
    {
      ssl_verifypeer: false, ssl_verifyhost: 2,
      headers: { 'User-Agent' => "CMSScanner v#{CMSScanner::VERSION}" },
      accept_encoding: 'gzip, deflate',
      method: :get
    }
  end

  describe '#forge_request' do
    it 'returns a Typhoeus::Request' do
      expect(browser.forge_request('http://example.com')).to be_a Typhoeus::Request
    end
  end

  describe '#default_request_params' do
    its(:default_request_params) { should eq default }

    context 'when some attributes are set' do
      let(:options)  do
        {
          cache_ttl: 200, connect_timeout: 10,
          http_auth: { username: 'log', password: 'pwd' },
          cookie_jar: '/tmp/cookie_jar.txt',
          vhost: 'testing'
        }
      end

      let(:expected) do
        default.merge(
          cache_ttl: 200, connecttimeout: 10, userpwd: 'log:pwd',
          cookiejar: options[:cookie_jar], cookiefile: options[:cookie_jar]
        ).merge(headers: default[:headers].merge('Host': 'testing'))
      end

      its(:default_request_params) { should eq expected }
    end
  end

  describe '#request_params' do
    context 'when no param is given' do
      its(:request_params) { should eq default }
    end

    context 'when params are supplied' do
      let(:params) { { another_param: true, headers: { 'Accept' => 'None' } } }

      it 'merges them (headers should be correctly merged)' do
        expect(browser.request_params(params)).to eq default
          .merge(params) { |key, oldval, newval| key == :headers ? oldval.merge(newval) : newval }
      end

      context 'when browser options' do
        let(:options) { { proxy: 'http://127.0.0.1:8080' } }

        it 'returns the correct hash' do
          expect(browser.request_params(params)).to eq default
            .merge(options)
            .merge(params) { |key, oldval, newval| key == :headers ? oldval.merge(newval) : newval }
        end
      end
    end
  end

  describe '#load_options' do
    context 'when no options' do
      it 'does not load anything' do
        described_class::OPTIONS.each do |sym|
          expected = case sym
                     when :user_agent
                       browser.default_user_agent
                     when :user_agents_list
                       File.join(CMSScanner::APP_DIR, 'user_agents.txt')
                     end

          expect(browser.send(sym)).to eq expected
        end
      end
    end

    context 'when options are supplied' do
      module CMSScanner
        # Test accessor
        class Browser
          attr_accessor :test
        end
      end

      let(:options) do
        { cache_ttl: 200, max_threads: 10, test: 'should not be set',
          user_agent: 'UA', proxy: false, user_agents_list: 'test.txt' }
      end

      it 'merges the browser options only' do
        described_class::OPTIONS.each do |sym|
          expected = options.key?(sym) ? options[sym] : nil

          expect(browser.send(sym)).to eq expected
        end

        expect(browser.test).to be nil
      end
    end
  end

  describe '#hydra' do
    context 'when #max_threads is nil' do
      its('hydra.max_concurrency') { should eq 1 }
    end

    context 'when #max_threads' do
      let(:options) { { max_threads: 20 } }

      its('hydra.max_concurrency') { should eq options[:max_threads] }
    end
  end

  describe '#max_threads=' do
    after do
      browser.max_threads = @threads

      expect(browser.max_threads).to eq @expected
      expect(browser.hydra.max_concurrency).to eq @expected
    end

    context 'when <= 0' do
      it 'sets the @threads to 1' do
        @threads  = -2
        @expected = 1
      end
    end

    context 'when > 0' do
      it 'sets the @threads' do
        @threads  = 20
        @expected = @threads
      end
    end
  end

  describe '#user_agent' do
    context 'when no --random-user-agent' do
      context 'when no --user-agent' do
        its(:user_agent) { should eql browser.default_user_agent }
      end

      context 'when --user-agent' do
        let(:options) { super().merge(user_agent: 'Test UA') }

        its(:user_agent) { should eql 'Test UA' }
      end
    end

    context 'when --random-user-agent' do
      let(:options) { super().merge(random_user_agent: true) }

      it 'select a random UA in the user_agents' do
        expect(browser.user_agent).to_not eql browser.default_user_agent
        # Should not pick up a random one each time
        expect(browser.user_agent).to eql browser.user_agent
      end
    end
  end

  describe '#user_agents' do
    let(:options) { { user_agents_list: File.join(FIXTURES, 'user_agents.txt') } }

    its(:user_agents) { should eql %w(UA-1 UA-2) }
  end
end

require 'spec_helper'

describe CMSScanner::Browser do

  it_behaves_like described_class::Actions

  subject(:browser) { described_class.instance(options) }
  before            { described_class.reset }
  let(:options)     { {} }

  describe '#forge_request' do
    it 'returns a Typhoeus::Request' do
      expect(browser.forge_request('http://example.com')).to be_a Typhoeus::Request
    end
  end

  describe '#request_params' do
    let(:default) do
      { cache_ttl: nil, connecttimeout: nil, maxredirs: 3,
        proxy: nil, proxyauth: nil,
        ssl_verifypeer: false, ssl_verifyhost: 2,
        timeout: nil, userpwd: nil,
        headers: { 'User-Agent' => "CMSScanner v#{CMSScanner::VERSION}" } }
    end

    context 'when no param is given' do
      its(:request_params) { should eq default }

      context 'when browser options' do
        let(:options) { { http_auth: { username: 'log', password: 'pwd' } } }

        its(:request_params) { should eq default.merge(userpwd: 'log:pwd') }
      end
    end

    context 'when params are supplied' do
      let(:params) { { maxredirs: 10, another_param: true, headers: { 'Accept' => 'None' } } }

      it 'merges them (headers should be correctly merged)' do
        expect(browser.request_params(params)).to eq default
          .merge(params) { |key, oldval, newval| key == :headers ? oldval.merge(newval) : newval }
      end

      context 'when browser options' do
        let(:options) { { maxredirs: 20, proxy: 'http://127.0.0.1:8080' } }

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
          expected = sym == :user_agent ? "CMSScanner v#{CMSScanner::VERSION}" : nil

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
        { cache_ttl: 200, threads: 10, test: 'should not be set',
          user_agent: 'UA', proxy: false }
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
    context 'when #threads is nil' do
      its('hydra.max_concurrency') { should eq 1 }
    end

    context 'when #threads' do
      let(:options) { { threads: 20 } }

      its('hydra.max_concurrency') { should eq options[:threads] }
    end
  end

  describe '#threads=' do
    after do
      browser.threads = @threads

      expect(browser.threads).to eq @expected
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
end

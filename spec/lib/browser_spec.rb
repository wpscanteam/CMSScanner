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
    let(:default) { { maxredirs: 3, ssl_verifypeer: false, ssl_verifyhost: 2 } }

    context 'when no param is given' do
      its(:request_params) { should eq default }
    end

    context 'when params are supplied' do
      let(:params) { { maxredirs: 10, another_param: true } }

      it 'merges them' do
        expect(browser.request_params(params)).to eq(default.merge(params))
      end
    end
  end

  describe '#load_options' do
    context 'when no options' do
      it 'does not load anything' do
        described_class::OPTIONS.each do |sym|
          expect(browser.send(sym)).to be nil
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

      let(:options) { { cache_ttl: 200, threads: 10, test: 'should not be set' } }

      it 'merges the browser options only' do
        described_class::OPTIONS.each do |sym|
          expected = options.key?(sym) ? options[sym] : nil

          expect(browser.send(sym)).to eq expected
        end

        expect(browser.test).to be nil
      end
    end
  end
end

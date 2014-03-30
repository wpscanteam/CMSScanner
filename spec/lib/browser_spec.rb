require 'spec_helper'

describe CMSScanner::Browser do

  it_behaves_like described_class::Actions

  subject(:browser) { described_class.instance }
  after             { described_class.reset }

  describe '#forge_request' do
    it 'returns a Typhoeus::Request' do
      expect(browser.forge_request('http://example.com')).to be_a Typhoeus::Request
    end
  end

  describe '#request_params' do
    let(:default) { { maxredirs: 3, ssl_verifypeer: false, ssl_verifyhost: 2 } }

    context 'when no param is given' do
      it 'returns the default params' do
        expect(browser.request_params).to eq(default)
      end
    end

    context 'when params are supplied' do
      let(:params) { { maxredirs: 10, another_param: true } }

      it 'merges them' do
        expect(browser.request_params(params)).to eq(default.merge(params))
      end
    end
  end
end

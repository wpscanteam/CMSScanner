require 'spec_helper'

describe CMSScanner::Browser do

  subject(:browser) { described_class.instance }
  after             { described_class.reset }

  describe '#forge_request' do
    it 'returns a Typhoeus::Request' do
      browser.forge_request('http://example.com').should be_a Typhoeus::Request
    end
  end

  describe '#request_params' do
    let(:default) { { maxredirs: 3, ssl_verifypeer: false, ssl_verifyhost: 2 } }

    context 'when no param is given' do
      it 'returns the default params' do
        browser.request_params.should eq(default)
      end
    end

    context 'when params are supplied' do
      let(:params) { { maxredirs: 10, another_param: true } }

      it 'merges them' do
        browser.request_params(params).should eq(default.merge(params))
      end
    end
  end
end

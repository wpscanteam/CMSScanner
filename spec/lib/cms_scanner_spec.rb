# frozen_string_literal: true

describe CMSScanner do
  let(:target_url) { 'http://wp.lab/' }

  before do
    scanner = CMSScanner::Scan.new
    scanner.controllers.first.class.parsed_options = rspec_parsed_options("--url #{target_url}")
  end

  describe 'typhoeus memoize' do
    it 'should be false' do
      expect(Typhoeus::Config.memoize).to be false
    end
  end

  describe 'typhoeus_on_complete' do
    before do
      CMSScanner.cached_requests = 0
      CMSScanner.total_requests = 0
      CMSScanner.total_data_sent = 0
      CMSScanner.total_data_received = 0
    end

    it 'returns the expected number of requests' do
      stub_request(:get, /.*/).and_return(body: 'aa', headers: { 'key' => 'field' })

      CMSScanner::Browser.get(target_url)

      expect(CMSScanner.cached_requests).to eql 0
      expect(CMSScanner.total_requests).to eql 1
      expect(CMSScanner.total_data_sent).to eql 0 # can't really test this one it seems
      expect(CMSScanner.total_data_received).to eql 29
    end

    context 'when cached request' do
      it 'returns the expected values' do
        allow_any_instance_of(Typhoeus::Response).to receive(:cached?).and_return(true)

        stub_request(:get, target_url)

        CMSScanner::Browser.get(target_url)
        CMSScanner::Browser.get(target_url)

        expect(CMSScanner.cached_requests).to eql 2
        expect(CMSScanner.total_requests).to eql 0
        expect(CMSScanner.total_data_sent).to eql 0
        expect(CMSScanner.total_data_received).to eql 0
      end
    end
  end

  describe '#start_memory' do
    it 'is set by Scan.new' do
      expect(CMSScanner.start_memory).to be_positive
    end
  end

  describe '#app_name' do
    it 'returns the excpected string' do
      expect(CMSScanner.app_name).to eql 'cms_scanner'
    end
  end
end

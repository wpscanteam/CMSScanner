require 'spec_helper'

describe CMSScanner::Cache::Typhoeus do

  subject(:cache) { described_class.new(cache_dir) }

  let(:cache_dir) { File.join(CACHE, 'typhoeus_cache') }
  let(:url)       { 'http://example.com' }
  let(:request)   { Typhoeus::Request.new(url, cache_ttl: 20) }
  let(:key)       { request.hash.to_s }

  describe '#get' do
    it 'calls #read_entry' do
      expect(cache).to receive(:read_entry).with(key)

      cache.get(request)
    end
  end

  describe '#set' do
    let(:response) { Typhoeus::Response.new }

    it 'calls #write_entry' do
      expect(cache).to receive(:write_entry).with(key, response, request.cache_ttl)

      cache.set(request, response)
    end
  end

end

# frozen_string_literal: true

describe CMSScanner::Cache::Typhoeus do
  subject(:cache) { described_class.new(cache_dir) }

  let(:cache_dir) { CACHE.join('typhoeus_cache') }
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
    context 'when response did not time out' do
      let(:response) { Typhoeus::Response.new(return_code: :ok, code: 200) }

      it 'calls #write_entry' do
        expect(cache).to receive(:write_entry).with(key, response, request.cache_ttl)

        cache.set(request, response)
      end
    end

    context 'when response timed out' do
      let(:response) { Typhoeus::Response.new(return_code: :operation_timedout) }

      it 'does not write the entry' do
        expect(cache).to_not receive(:write_entry)

        cache.set(request, response)
      end
    end

    context 'when response code is 0' do
      let(:response) { Typhoeus::Response.new(code: 0) }

      it 'does not write the entry' do
        expect(cache).to_not receive(:write_entry)

        cache.set(request, response)
      end
    end
  end
end

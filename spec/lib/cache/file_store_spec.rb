require 'spec_helper'

describe CMSScanner::Cache::FileStore do

  let(:cache_dir) { File.join(CACHE, 'cache_file_store') }
  subject(:cache) { described_class.new(cache_dir) }

  before { FileUtils.rm_r(cache_dir, secure: true) if Dir.exist?(cache_dir) }
  after  { cache.clean }

  describe '#new, #storage_path, #serializer' do
    its(:serializer)   { should be Marshal }
    its(:storage_path) { should eq cache_dir }
  end

  describe '#clean' do
    it 'removes all files from the cache dir' do
      # let's create some files into the directory first
      (0..5).each do |i|
        File.new(File.join(cache.storage_path, "file_#{i}.txt"), File::CREAT)
      end

      expect(count_files_in_dir(cache.storage_path, 'file_*.txt')).to eq 6
      cache.clean
      expect(count_files_in_dir(cache.storage_path)).to eq 0
    end
  end

  describe '#read_entry?' do
    let(:key) { 'key1' }

    after do
      File.write(cache.entry_expiration_path(key), @expiration) if @expiration

      expect(cache.read_entry(key)).to eq @expected
    end

    context 'when the entry does not exists' do
      it 'returns nil' do
        @expected = nil
      end
    end

    context 'when the file is empty (marshal data too short error)' do
      it 'returns nil' do
        File.new(cache.entry_path(key), File::CREAT)

        @expiration = Time.now.to_i + 200
        @expected   = nil
      end
    end

    context 'when the entry has expired' do
      it 'returns nil' do
        @expiration = Time.now.to_i - 200
        @expected   = nil
      end
    end

    context 'when the entry has not expired' do
      it 'returns the entry' do
        File.write(cache.entry_path(key), cache.serializer.dump('testing data'))

        @expiration = Time.now.to_i + 600
        @expected   = 'testing data'
      end
    end
  end

  describe '#write_entry' do
    after do
      cache.write_entry(@key, @data, @ttl)
      expect(cache.read_entry(@key)).to eq @expected
    end

    it 'should get the correct entry (string)' do
      @ttl      = 10
      @key      = 'some_key'
      @data     = 'Hello World !'
      @expected = @data
    end

    context 'when cache_ttl <= 0' do
      it 'does not write the entry' do
        @ttl      = 0
        @key      = 'another_key'
        @data     = 'Another Hello World !'
        @expected = nil
      end
    end

    context 'when cache_ttl is nil' do
      it 'does not write the entry' do
        @ttl      = nil
        @key      = 'test'
        @data     = 'test'
        @expected = nil
      end
    end
  end
end

require 'spec_helper'

describe CMSScanner::Target do

  subject(:target) { described_class.new(url) }
  let(:url)        { 'http://ex.lo' }

  describe '#in_scope?' do
    after { expect(target.in_scope?(@url)).to eq @expected }

    [nil, '', 'http://out-of-scope.com', '//jquery.com/j.js'].each do |url|
      it "returns false for #{url}" do
        @url      = url
        @expected = false
      end
    end

    %w(https://ex.lo/file.txt http://ex.lo/ /relative).each do |url|
      it "returns true for #{url}" do
        @url      = url
        @expected = true
      end
    end
  end

  describe '#interesting_files' do
    before do
      expect(CMSScanner::Finders::InterestingFiles).to receive(:find).and_return(stubbed)
    end

    context 'when no findings' do
      let(:stubbed) { [] }

      its(:interesting_files) { should eq stubbed }
    end

    context 'when findings' do
      let(:stubbed) { ['yolo'] }

      it 'allows findings to be added with <<' do
        expect(target.interesting_files).to eq stubbed

        target.interesting_files << 'other-finding'

        expect(target.interesting_files).to eq(stubbed << 'other-finding')
      end
    end
  end

end

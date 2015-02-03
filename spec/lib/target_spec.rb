require 'spec_helper'

describe CMSScanner::Target do
  subject(:target) { described_class.new(url, opts) }
  let(:url)        { 'http://e.org' }
  let(:opts)       { { scope: nil } }

  describe '#scope' do
    let(:default_domains) { [PublicSuffix.parse('e.org')] }

    context 'when none supplied' do
      its('scope.domains') { should eq default_domains }
    end

    context 'when scope provided' do
      let(:opts) { super().merge(scope: ['*.e.org']) }

      its('scope.domains') { should eq default_domains << PublicSuffix.parse(opts[:scope].first) }

      context 'when invalid domains provided' do
        let(:opts) { super().merge(scope: ['wp-lamp', '192.168.1.12']) }

        it 'adds them in the invalid_domains attribute' do
          expect(target.scope.domains).to eq default_domains
          expect(target.scope.invalid_domains).to eq opts[:scope]
        end
      end
    end
  end

  describe '#in_scope?' do
    context 'when default scope (target domain)' do
      [nil, '', 'http://out-of-scope.com', '//jquery.com/j.js'].each do |url|
        it "returns false for #{url}" do
          expect(target.in_scope?(url)).to eql false
        end
      end

      %w(https://e.org/file.txt http://e.org/ /relative).each do |url|
        it "returns true for #{url}" do
          expect(target.in_scope?(url)).to eql true
        end
      end
    end

    context 'when custom scope' do
      let(:opts) { { scope: ['*.e.org'] } }

      [nil, '', 'http://out-of-scope.com', '//jquery.com/j.js'].each do |url|
        it "returns false for #{url}" do
          expect(target.in_scope?(url)).to eql false
        end
      end

      %w(https://cdn.e.org/file.txt http://www.e.org/).each do |url|
        it "returns true for #{url}" do
          expect(target.in_scope?(url)).to eql true
        end
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

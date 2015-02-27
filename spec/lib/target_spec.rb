require 'spec_helper'

describe CMSScanner::Target do
  subject(:target) { described_class.new(url) }
  let(:url)        { 'http://e.org' }

  describe '#interesting_files' do
    before do
      expect(CMSScanner::Finders::InterestingFiles::Base).to receive(:find).and_return(stubbed)
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

  describe '#comments_from_page' do
    let(:fixture) { File.join(FIXTURES, 'target', 'comments.html') }
    let(:page) { Typhoeus::Response.new(body: File.read(fixture)) }

    context 'when the pattern does not match anything' do
      it 'returns an empty array' do
        expect(target.comments_from_page(/none/, page)).to eql([])
      end
    end

    context 'when the pattern matches' do
      let(:pattern) { /all in one seo pack/i }
      let(:s1) { 'All in One SEO Pack 2.2.5.1 by Michael Torbert of Semper Fi Web Design' }
      let(:s2) { '/all in one seo pack' }

      context 'when no block given' do
        it 'returns the expected matches' do
          results = target.comments_from_page(pattern, page)

          [s1, s2].each_with_index do |s, i|
            expect(results[i].first).to eql s.match(pattern)
            expect(results[i].last.to_s).to eql "<!-- #{s} -->"
          end
        end
      end

      # The below doesn't work, dunno why
      context 'when block given' do
        it 'yield the MatchData' do
          expect { |b| target.comments_from_page(pattern, page, &b) }
            .to yield_successive_args(
              [MatchData, Nokogiri::XML::Comment],
              [MatchData, Nokogiri::XML::Comment]
            )
        end
      end
    end
  end
end

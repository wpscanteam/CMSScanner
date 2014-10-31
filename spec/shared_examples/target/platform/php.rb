
shared_examples CMSScanner::Target::Platform::PHP do

  before { stub_request(:get, target.url(path)).to_return(body: body) }

  describe '#debug_log?' do
    let(:path) { 'd.log' }

    context 'when the body matches' do
      %w(debug.log).each do |file|
        context "when #{file} body" do
          let(:body) { File.read(File.join(fixtures, 'debug_log', file)) }

          it 'returns true' do
            expect(target.debug_log?(path)).to be true
          end
        end
      end
    end

    context 'when the body does not match' do
      let(:body) { '' }

      it 'returns false' do
        expect(target.debug_log?(path)).to be false
      end
    end
  end

  describe '#full_path_disclosure?, #full_path_disclosure_entries' do
    let(:path) { 'p.php' }

    context 'when the body matches a FPD' do
      {
        'wp_rss_functions.php' => %w(/short-path/rss-f.php)
      }.each do |file, expected|
        context "when #{file} body" do
          let(:body) { File.read(File.join(fixtures, 'fpd', file)) }

          it 'returns the expected array' do
            expect(target.full_path_disclosure_entries(path)).to eql expected
            expect(target.full_path_disclosure?(path)).to be true
          end
        end
      end
    end

    context 'when no FPD' do
      let(:body) { '' }

      it 'returns an empty array' do
        expect(target.full_path_disclosure_entries(path)).to eq []
        expect(target.full_path_disclosure?(path)).to be false
      end
    end
  end
end

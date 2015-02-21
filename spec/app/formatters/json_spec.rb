require 'spec_helper'

describe CMSScanner::Formatter::Json do
  it_behaves_like CMSScanner::Formatter::Buffer

  subject(:formatter) { described_class.new }
  let(:output_file)   { File.join(FIXTURES, 'output.txt') }

  before { formatter.views_directories << FIXTURES_VIEWS }

  its(:format)            { should eq 'json' }
  its(:user_interaction?) { should be false }

  describe '#output' do
    it 'puts the rendered text in the buffer' do
      2.times { formatter.output('@render_me', test: 'Working') }

      expect(formatter.buffer).to eq "\"test\": \"Working\",\n" * 2
    end
  end

  describe '#beautify' do
    it 'writes the buffer in the file' do
      2.times { formatter.output('@render_me', test: 'yolo') }

      expect($stdout).to receive(:puts).with(JSON.pretty_generate(JSON.parse('{"test": "yolo"}')))
      formatter.beautify
    end
  end
end

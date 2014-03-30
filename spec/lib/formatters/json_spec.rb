require 'spec_helper'

describe CMSScanner::Formatter::Json do

  subject(:formatter) { described_class.new }
  let(:output_file)   { File.join(FIXTURES, 'output.txt') }

  before { formatter.views_directories << FIXTURES_VIEWS }

  describe '#format' do
    its(:format) { should eq 'json' }
  end

  describe '#buffer' do
    its(:buffer) { should be_empty }
  end

  describe '#output' do
    it 'puts the rendered text in the buffer' do
      2.times { formatter.output('@render_me', test: 'Working') }

      formatter.buffer.should eq '"test": "Working","test": "Working",'
    end
  end

  describe '#beautify' do
    it 'writes the buffer in the file' do
      formatter.output('@render_me', test: 'yolo')

      $stdout.should_receive(:puts).with(JSON.pretty_generate(JSON.parse('{"test": "yolo"}')))
      formatter.beautify
    end
  end

end


shared_examples CMSScanner::Finders::Finding do

  [:references, :confirmed_by, :interesting_entries].each do |opt|
    describe "##{opt}" do
      its(opt) { should eq [] }

      context 'when supplied in the #new' do
        let(:opts) { { opt => 'test' } }

        its(opt) { should eq 'test' }
      end
    end
  end

  describe '#parse_finding_options' do
    xit
  end

end

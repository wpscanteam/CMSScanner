
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

  describe '#confidence' do
    its(:confidence) { should eql 0 }

    context 'when already set' do
      before { subject.confidence = 10 }

      its(:confidence) { should eql 10 }
    end
  end

  describe '#parse_finding_options' do
    xit
  end

end


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

  describe '#confidence, #confidence=' do
    its(:confidence) { should eql 0 }

    context 'when already set' do
      before { subject.confidence = 10 }

      its(:confidence) { should eql 10 }
    end
  end

  describe '#parse_finding_options' do
    xit
  end

  describe '#eql?' do
    before do
      subject.confidence = 10
      subject.found_by = 'test'
    end

    context 'when eql' do
      it 'returns true' do
        expect(subject).to eql subject
      end
    end

    context 'when not eql' do
      it 'returns false' do
        other = subject.dup
        other.confidence = 20

        expect(subject).to_not eql other
      end
    end
  end
end

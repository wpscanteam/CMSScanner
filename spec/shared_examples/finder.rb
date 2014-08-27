
shared_examples CMSScanner::Finder do

  describe '::find' do
    it 'creates a new object and call finders#find' do
      created = described_class.new(target)

      expect(described_class).to receive(:new).and_return(created)
      expect(created).to receive(:find)

      described_class.find(target)
    end
  end

  describe '#find' do
    it 'calls finders#run' do
      expect(subject.finders).to receive(:run).with(:mixed)
      subject.find
    end
  end

  describe '#finders' do
    it 'returns the correct finders' do
      finders = subject.finders

      expect(finders.size).to eq expected_finders.size
      expect(finders.map { |f| f.class.to_s.demodulize }).to eq expected_finders
    end
  end

end

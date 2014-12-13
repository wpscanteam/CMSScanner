
shared_examples 'App::Views::InterestingFiles' do
  let(:controller)       { CMSScanner::Controller::InterestingFiles.new }
  let(:tpl_vars)         { { url: target_url } }
  let(:interesting_file) { CMSScanner::InterestingFile }

  describe 'findings' do
    let(:view) { 'findings' }
    let(:opts) { { confidence: 10, found_by: 'Spec' } }

    context 'when empty results' do
      let(:expected_view) { 'empty' }

      it 'outputs the expected string' do
        @tpl_vars = tpl_vars.merge(findings: [])
      end
    end

    it 'outputs the expected string' do
      findings = CMSScanner::Finders::Findings.new

      findings <<
        interesting_file.new('F1', opts) <<
        interesting_file.new('F2', opts.merge(references: %w(R1), interesting_entries: %w(IE1))) <<
        interesting_file.new('F2', opts.merge(found_by: 'Spec2')) <<
        interesting_file.new('F3',
                             opts.merge(references: %w(R1 R2), interesting_entries: %w(IE1 IE2))) <<
        interesting_file.new('F3', opts.merge(found_by: 'Spec2', confidence: 100)) <<
        interesting_file.new('F3', opts.merge(found_by: 'Spec3')) <<
        interesting_file.new('F4', opts.merge(confidence: 0)) <<
        interesting_file.new('F4', opts.merge(confidence: 0, found_by: 'Spec2'))

      @tpl_vars = tpl_vars.merge(findings: findings)
    end
  end
end

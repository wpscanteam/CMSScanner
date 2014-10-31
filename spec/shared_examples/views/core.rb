
shared_examples 'App::Views::Core' do

  let(:controller) { CMSScanner::Controller::Core.new }
  let(:tpl_vars)   { { url: target_url, start_time: Time.parse('2014-10-30 13:02:01 +0100 DST') } }

  describe 'started' do
    let(:view) { 'started' }

    it 'outputs the expected string' do
      @tpl_vars = tpl_vars.merge(start_memory: 10)
    end
  end

  describe 'finished' do
    let(:view) { 'finished' }

    it 'outputs the expected string' do
      @tpl_vars = tpl_vars.merge(
        stop_time: Time.parse('2014-10-30 13:02:03 +0100 DST'),
        used_memory: 100,
        elapsed: 3
      )
    end
  end
end

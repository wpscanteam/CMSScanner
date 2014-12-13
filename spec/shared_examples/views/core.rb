
shared_examples 'App::Views::Core' do
  let(:controller) { CMSScanner::Controller::Core.new }
  let(:start)      { Time.at(1_414_670_521).in_time_zone('Europe/London') }
  let(:tpl_vars)   { { url: target_url, start_time: start } }

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
        stop_time: Time.at(1_414_670_523).in_time_zone('Europe/London'),
        used_memory: 100,
        elapsed: 2
      )
    end
  end
end

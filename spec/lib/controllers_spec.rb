require 'spec_helper'

module CMSScanner
  module Controller
    class Spec < Base
    end
  end
end

describe CMSScanner::Controllers do

  subject(:controllers)  { described_class.new }
  let(:controller_mod) { CMSScanner::Controller }

  describe '#<<' do
    its(:size) { should be 0 }

    context 'when controllers are added' do
      before { controllers << controller_mod::Spec.new << controller_mod::Base.new }

      its(:size) { should be 2 }
    end

    context 'when a controller is added twice' do
      before { 2.times { controllers << controller_mod::Spec.new } }

      its(:size) { should be 1 }
    end

    it 'returns self' do
      expect(controllers << controller_mod::Spec.new).to be_a described_class
    end
  end

  describe '#run' do
    let(:views) { %w(/path/views1 /path2/views) }

    it 'runs the before_scan, run and after_scan methods of each controller' do
      spec = controller_mod::Spec.new
      base = controller_mod::Base.new

      controllers << spec << base

      # TODO: Any way to test the orders ? (after_scan should reverse the order)
      [base, spec].each do |c|
        expect(c).to receive(:before_scan)
        expect(c).to receive(:run)
        expect(c).to receive(:after_scan)
      end
      controllers.run(custom_views: views)

      expect(controllers.first.formatter.views_directories)
        .to include('/path/views1', '/path2/views')
    end
  end

end

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
      (controllers << controller_mod::Spec.new).should be_a described_class
    end
  end

  describe '#run' do
    it 'runs the before_scan, run and after_scan methods of each controller' do
      spec = controller_mod::Spec.new
      base = controller_mod::Base.new

      controllers << spec << base

      # TODO: Any way to test the orders ? (after_scan should reverse the order)
      [base, spec].each do |c|
        c.should_receive(:before_scan)
        c.should_receive(:run)
        c.should_receive(:after_scan)
      end
      controllers.run
    end
  end

end

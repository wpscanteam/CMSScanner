require 'spec_helper'

describe 'App::Views' do

  let(:target_url) { 'http://ex.lo/' }
  let(:fixtures)   { File.join(SPECS, 'output') }

  # CliNoColour is used to test the CLI output to avoid the painful colours
  # in the expected output.
  [:CliNoColour].each do |formatter|
    context "when #{formatter}" do

      it_behaves_like 'App::Views::Core'
      it_behaves_like 'App::Views::InterestingFiles'

      let(:parsed_options) { { url: target_url, format: formatter.to_s.underscore.dasherize } }

      before do
        controller.class.parsed_options = parsed_options
        # Resets the formatter to ensure the correct one is loaded
        controller.class.class_variable_set(:@@formatter, nil)
      end

      after do
        view_filename  = "#{view}.#{formatter.to_s.underscore.downcase}"
        controller_dir = controller.class.to_s.demodulize.underscore.downcase
        output         = File.read(File.join(fixtures, controller_dir, view_filename))

        expect($stdout).to receive(:puts).with(output)

        controller.output(view, @tpl_vars)
      end
    end
  end
end

#!/usr/bin/env ruby

require 'cms_scanner'

# Custom WPScan Scanner
module WPScan
  include CMSScanner

  module Controller
    # Custom WPScan Controller
    class WpCustom < CMSScanner::Controller::Base
      def cli_options
        [
          OptString.new(['--wpscan-option VALUE'])
        ]
      end

      def run
        output('test', option: parsed_options[:wpscan_option])
      end
    end
  end
end

WPScan::Scan.new do |s|
  s.controllers << WPScan::Controller::WpCustom.new
  s.run
end

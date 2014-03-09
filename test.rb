$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'cms_scanner'

scanner = CMSScanner::Scan.new
scanner.controllers << CMSScanner::Controller::Custom.new

scanner.run

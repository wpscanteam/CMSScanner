# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'simplecov' # More config is defined in ./.simplecov
require 'rspec/its'
require 'webmock/rspec'
require 'active_support/deprecation'
require 'active_support/time'

# See http://betterspecs.org/
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def count_files_in_dir(absolute_dir_path, files_pattern = '*')
  Dir.glob(File.join(absolute_dir_path, files_pattern)).count
end

# Parse a file containing raw headers and return the associated Hash
# @return [ Hash ]
def parse_headers_file(filepath)
  Typhoeus::Response::Header.new(File.read(filepath))
end

require 'cms_scanner'
require 'shared_examples'

def rspec_parsed_options(args)
  controllers = CMSScanner::Controllers.new <<
                CMSScanner::Controller::Core.new <<
                CMSScanner::Controller::InterestingFindings.new

  controllers.option_parser.results(args.split)
end

# TODO: remove when https://github.com/bblimke/webmock/issues/552 fixed
# rubocop:disable all
module WebMock
  module HttpLibAdapters
    class TyphoeusAdapter < HttpLibAdapter
      def self.effective_url(effective_uri)
        effective_uri.port = nil if effective_uri.scheme == 'http' && effective_uri.port == 80
        effective_uri.port = nil if effective_uri.scheme == 'https' && effective_uri.port == 443

        effective_uri.to_s
      end

      def self.generate_typhoeus_response(request_signature, webmock_response)
        response = if webmock_response.should_timeout
                     ::Typhoeus::Response.new(
                       code: 0,
                       status_message: '',
                       body: '',
                       headers: {},
                       return_code: :operation_timedout
                     )
                   else
                     ::Typhoeus::Response.new(
                       code: webmock_response.status[0],
                       status_message: webmock_response.status[1],
                       body: webmock_response.body,
                       headers: webmock_response.headers,
                       effective_url: effective_url(request_signature.uri)
                     )
        end
        response.mock = :webmock
        response
      end
    end
  end
end
# rubocop:enabled all

SPECS                 = Pathname.new(__FILE__).dirname
CACHE                 = SPECS.join('cache')
FIXTURES              = SPECS.join('fixtures')
FIXTURES_VIEWS        = FIXTURES.join('views')
FIXTURES_FINDERS      = FIXTURES.join('finders')
FIXTURES_MODELS       = FIXTURES.join('models')
FIXTURES_CONTROLLERS  = FIXTURES.join('controllers')
APP_VIEWS             = File.join(CMSScanner::APP_DIR, 'views')
ERROR_404_URL_PATTERN = %r{/[a-z\d]{7}\.html$}

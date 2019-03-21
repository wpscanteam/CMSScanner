# frozen_string_literal: true

module CMSScanner
  module Error
    class Standard < StandardError
    end
  end
end

require_relative 'errors/http'
require_relative 'errors/scan'

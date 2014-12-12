require 'dummy_finding'

module CMSScanner
  module Finders
    module Independent
      # Dummy Test Finder
      class DummyFinder < Finder
        def passive(_opts = {})
          DummyFinding.new('test', found_by: found_by)
        end

        def aggressive(_opts = {})
          DummyFinding.new('test', confidence: 100, found_by: 'override')
        end
      end

      # No aggressive result finder
      class NoAggressiveResult < Finder
        def passive(_opts = {})
          DummyFinding.new('spotted', confidence: 10, found_by: found_by)
        end
      end
    end
  end
end

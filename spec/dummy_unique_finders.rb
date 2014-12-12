require 'dummy_finding'

module CMSScanner
  module Finders
    module Unique
      # Dummy Test Finder
      class Dummy < Finder
        def passive(_opts = {})
          DummyFinding.new('test', found_by: found_by)
        end

        def aggressive(_opts = {})
          DummyFinding.new('test', confidence: 100, found_by: 'override')
        end
      end

      # No aggressive result
      class NoAggressive < Finder
        def passive(_opts = {})
          DummyFinding.new('spotted', confidence: 10, found_by: found_by)
        end
      end

      # Dummy2
      class Dummy2 < Finder
        def aggressive(_opts = {})
          DummyFinding.new('test2', confidence: 90)
        end
      end
    end
  end
end

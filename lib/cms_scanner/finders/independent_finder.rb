module CMSScanner
  module Finders
    # Independent Finder
    module IndependentFinder
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Hack to have the #find as a class method
      module ClassMethods
        def find(target, opts = {})
          new(target).find(opts)
        end
      end

      # @param [ Hash ] opts
      # @option opts [ Symbol ] mode (:mixed, :passive, :aggressive)
      #
      # @return [ Findings ]
      def find(opts = {})
        finders.run(opts)
      end

      # @return [ Array ]
      def finders
        @finders ||= NS::Finders::IndependentFinders.new
      end
    end
  end
end

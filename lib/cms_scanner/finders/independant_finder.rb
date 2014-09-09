module CMSScanner
  module Finders
    # Independant Finder
    module IndependantFinder
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
        @finders ||= IndependtantFinders.new
      end
    end
  end
end

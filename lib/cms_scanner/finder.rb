require 'cms_scanner/finder/base'
require 'cms_scanner/finder/finding'
require 'cms_scanner/finder/findings'
require 'cms_scanner/finder/finders'

module CMSScanner
  # Finder module
  module Finder
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Hack to have the #find as a class method
    module ClassMethods
      def find(target, mode = :mixed)
        new(target).find(mode)
      end
    end

    # @param [ Symbol ] mode (:mixed, :passive, :aggressive)
    #
    # @return [ Findings ]
    def find(mode = :mixed)
      finders.run(mode)
    end

    # @return [ Array ]
    def finders
      @finders ||= Finders.new
    end
  end
end

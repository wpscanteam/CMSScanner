module CMSScanner
  module Finders
    # Same Type Finders container
    #
    # This class is designed to handle same type results, such as enumeration of plugins,
    # themes etc.
    class SameTypeFinders < IndependentFinders
      # @param [ Hash ] opts
      # @option opts [ Symbol ] :mode :mixed, :passive or :aggressive
      #
      # @return [ Findings ]
      def run(opts = {})
        symbols_from_mode(opts[:mode]).each do |symbol|
          each do |finder|
            [*finder.send(symbol, opts.merge(found: findings))].compact.each do |found|
              findings << found
            end
          end
        end

        findings
      end
    end
  end
end

module CMSScanner
  module Finders
    # Same Type Finders container
    #
    # This class is designed to handle same type results, such as enumeration of plugins,
    # themes etc.
    class SameTypeFinders < IndependentFinders
      # @param [ Hash ] opts
      # @option opts [ Symbol ] :mode :mixed, :passive or :aggressive
      # @option opts [ Boolean ] :sort Wether or not to sort the findings
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

        findings.sort! if opts[:sort]

        findings
      end
    end
  end
end

module CMSScanner
  module Finders
    # Unique Finders container
    #
    # This class is designed to return a unique result such as a version
    # Note: Finders contained can return multiple results but the #run will only
    # returned the best finding
    class UniqueFinders < IndependentFinders
      # @param [ Hash ] opts
      # @option opts [ Symbol ] mode :mixed, :passive or :aggressive
      # @option opts [ Boolean ] check_all If true, the best result is not returned until all
      #                                    finders have been run.
      #
      # @return [ Findings ]
      def run(opts = {})
        symbols_from_mode(opts[:mode]).each do |symbol|
          each do |finder|
            [*finder.send(symbol, opts)].each do |found|
              findings << found
            end

            next if opts[:check_all]

            findings.each do |f|
              return f if f.confidence >= 100
            end
          end
        end

        findings.sort_by(&:confidence).reverse.first
      end
    end
  end
end

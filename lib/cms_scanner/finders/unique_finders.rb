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
      #
      # @return [ Findings ]
      def run(opts = {})
        symbols_from_mode(opts[:mode]).each do |symbol|
          each do |finder|
            # not sure if the below will work
            # Will see with rspec
            (findings + [*finder.send(symbol, opts)]).each { |f| return f if f.confidence >= 100 }
          end
        end

        findings.sort_by(&:confidence).first
      end
    end
  end
end

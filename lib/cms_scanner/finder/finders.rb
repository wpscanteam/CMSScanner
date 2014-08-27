module CMSScanner
  module Finder
    # Finder container
    class Finders < Array
      # @return [ Findings ]
      def findings
        @findings ||= Findings.new
      end

      # @param [ Symbol ] mode :mixed, :passive or :aggressive
      # @param [ Hash ] opts
      #
      # @return [ Findings ]
      def run(mode = :mixed, opts = {})
        each do |finder|
          symbols_from_mode(mode).each do |symbol|
            r = finder.send(symbol, opts)

            next unless r

            findings << create_finding(r, finder, symbol)
            break
          end
        end

        findings
      end

      # @param [ symbol ] mode :mixed, :passive or :aggressive
      # @return [ Array<Symbol> ] The symbols to call for the mode
      def symbols_from_mode(mode)
        symbols = [:passive, :aggressive]

        return symbols if mode == :mixed
        symbols.include?(mode) ? [*mode] : []
      end

      # Create the finding object related to the result
      #
      # @param [ Mixed ] result
      # @param [ Finder ] finder
      # @param [ Symbol ] symbol
      #
      # @return [ Finding ]
      def create_finding(result, finder, symbol)
        method = "#{finder.class.to_s.demodulize} (#{symbol} detection)"

        if result.is_a?(Hash) && result.key?(:result)
          r          = result[:result]
          method     = result[:method] if result.key?(:method)
          confidence = result[:confidence] if result.key?(:confidence)
        end

        Finding.new(r || result, method, confidence)
      end
    end
  end
end

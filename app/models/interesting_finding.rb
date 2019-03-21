# frozen_string_literal: true

module CMSScanner
  module Model
    # Interesting Finding
    class InterestingFinding
      include Finders::Finding

      attr_reader :url
      attr_writer :to_s

      # @param [ String ] url
      # @param [ Hash ] opts
      #   :to_s (override the to_s method)
      #   See Finders::Finding for other available options
      def initialize(url, opts = {})
        @url  = url
        @to_s = opts[:to_s]

        parse_finding_options(opts)
      end

      # @return [ Array<String> ]
      def entries
        res = NS::Browser.get(url)

        return [] unless res && res.headers['Content-Type'] =~ %r{\Atext/plain;}i

        res.body.split("\n").reject { |s| s.strip.empty? }
      end

      # @return [ String ]
      def to_s
        @to_s || url
      end

      # @return [ String ]
      def type
        @type ||= self.class.to_s.demodulize.underscore
      end

      # @return [ Boolean ]
      def ==(other)
        self.class == other.class && to_s == other.to_s
      end
    end
  end
end

module CMSScanner
  # Formatter
  module Formatter
    # @param [ String ] format
    #
    # @return [ Formatter ]
    def self.load(format = nil)
      format ||= 'CLI' # default format

      const_get(format).new
    end

    # Base Formatter
    class Base
      def format; end

      # @param [ String ] tpl
      # @param [ Hash ] vars
      def render(tpl, vars)
      end

      # @param [ String ] tpl
      # @return [ String ] The view file path
      def view_file(tpl)
        fail "Wrong tpl format: '#{tpl}'" unless tpl =~ /\A[\w\/]+\z/

        views_directories.reverse.each do |dir|
          potential_file = File.join(dir, format, "#{tpl}.erb")

          return potential_file if File.exist?(potential_file)
        end

        fail "View not found for #{tpl}"
      end

      def views_directories
        @views_directories ||= []
      end
    end
  end
end

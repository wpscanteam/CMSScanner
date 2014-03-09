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
        view(tpl).render(vars)
      end

      # @param [ String ] tpl
      #
      # @return [ View ] The view
      def view(tpl)
        fail "Wrong tpl format: '#{tpl}'" unless tpl =~ /\A[\w\/]+\z/

        views_directories.reverse.each do |dir|
          potential_file = File.join(dir, format, "#{tpl}.erb")

          return View.new(potential_file) if File.exist?(potential_file)
        end

        fail "View not found for #{tpl}"
      end

      def views_directories
        @views_directories ||= [Pathname.new(__FILE__).dirname.join('..', 'views').to_s]
      end
    end
  end
end

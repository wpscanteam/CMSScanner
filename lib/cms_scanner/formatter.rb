module CMSScanner
  # Formatter
  module Formatter
    # @param [ String ] format
    #
    # @return [ Formatter ]
    def self.load(format = nil)
      format ||= 'cli' # default format

      const_get(format.capitalize).new
    end

    # Base Formatter
    class Base
      def format
        self.class.name.demodulize.downcase
      end

      # This is called after the scan
      # and used in some formatters (e.g JSON)
      # to indent results
      def beautify; end

      # @see #render
      def output(tpl, vars = {})
        puts render(tpl, vars)
      end

      # @param [ String ] tpl
      # @param [ Hash ] vars
      def render(tpl, vars = {})
        template_vars(vars)

        ERB.new(File.read(view_path(tpl))).result(binding)
      end

      # @return [ Void ]
      def template_vars(vars)
        vars.each { |key, value| instance_variable_set("@#{key}", value) }
      end

      # @param [ String ] tpl
      #
      # @return [ String ] The path of the view
      def view_path(tpl)
        fail "Wrong tpl format: '#{tpl}'" unless tpl =~ /\A[\w\/]+\z/

        views_directories.reverse.each do |dir|
          potential_file = File.join(dir, format, "#{tpl}.erb")

          return potential_file if File.exist?(potential_file)
        end

        fail "View not found for #{tpl}"
      end

      def views_directories
        @views_directories ||= [Pathname.new(__FILE__).dirname.join('..', 'views').to_s]
      end
    end
  end
end

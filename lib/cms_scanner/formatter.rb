require 'cms_scanner/formatter/buffer'

module CMSScanner
  # Formatter
  module Formatter
    # @param [ String ] format
    # @param [ Array<String> ] custom_views
    #
    # @return [ Formatter::Base ]
    def self.load(format = nil, custom_views = nil)
      format       ||= 'cli'
      custom_views ||= []

      f = const_get(format.gsub(/-/, '_').camelize).new
      custom_views.each { |v| f.views_directories << v }
      f
    end

    # @return [ Array<String> ] The list of the available formatters (except the Base one)
    # @note: the #load method above should then be used to create the associated formatter
    def self.availables
      formatters = Formatter.constants.select do |const|
        name = Formatter.const_get(const)
        name.is_a?(Class) && name != Formatter::Base
      end

      formatters.map { |sym| sym.to_s.underscore.dasherize }
    end

    # Base Formatter
    class Base
      attr_reader :controller_name

      # @return [ String ] The underscored name of the class
      def format
        self.class.name.demodulize.underscore
      end

      # @return [ String ] The underscored format to use as a base
      def base_format; end

      # @return [ Array<String> ]
      def formats
        [format, base_format].compact
      end

      # This is called after the scan
      # and used in some formatters (e.g JSON)
      # to indent results
      def beautify; end

      # @see #render
      def output(tpl, vars = {}, controller_name = nil)
        puts render(tpl, vars, controller_name)
      end

      # @param [ String ] tpl
      # @param [ Hash ] vars
      # @param [ String ] controller_name
      def render(tpl, vars = {}, controller_name = nil)
        template_vars(vars)
        @controller_name = controller_name if controller_name

        # '-' is used to disable new lines when -%> is used
        # See http://www.ruby-doc.org/stdlib-2.1.1/libdoc/erb/rdoc/ERB.html
        ERB.new(File.read(view_path(tpl)), nil, '-').result(binding)
      end

      # @param [ Hash ] vars
      #
      # @return [ Void ]
      def template_vars(vars)
        vars.each do |key, value|
          instance_variable_set("@#{key}", value) unless key == :views_directories
        end
      end

      # @param [ String ] tpl
      #
      # @return [ String ] The path of the view
      def view_path(tpl)
        if tpl[0, 1] == '@' # Global Template
          tpl = tpl.delete('@')
        else
          fail 'The controller_name can not be nil' unless controller_name
          tpl = "#{controller_name}/#{tpl}"
        end

        fail "Wrong tpl format: '#{tpl}'" unless tpl =~ /\A[\w\/_]+\z/

        views_directories.reverse.each do |dir|
          formats.each do |format|
            potential_file = File.join(dir, format, "#{tpl}.erb")

            return potential_file if File.exist?(potential_file)
          end
        end

        fail "View not found for #{format}/#{tpl}"
      end

      # @return [ Array<String> ] The directories to look into for views
      def views_directories
        @views_directories ||= [Pathname.new(APP_DIR).join('views').to_s]
      end
    end
  end
end

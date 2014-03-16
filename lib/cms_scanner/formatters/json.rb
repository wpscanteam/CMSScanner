module CMSScanner
  module Formatter
    # JSON Formatter
    class Json < Base
      def output(tpl, vars = {})
        buffer << render(tpl, vars)
      end

      def buffer
        @buffer ||= ''
      end

      def beautify
        puts JSON.pretty_generate(JSON.parse("{#{buffer.chomp(',')}}"))
      end
    end
  end
end

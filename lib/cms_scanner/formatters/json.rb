module CMSScanner
  module Formatter
    # JSON Formatter
    class Json < Base
      def output(tpl, vars = {})
        @buffer ||= render(tpl, vars)
      end

      def beautify
        puts JSON.pretty_generate(JSON.parse("{#{@buffer}}"))
      end
    end
  end
end

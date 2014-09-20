module HttpReader
  class BasePageParser
    @pattern = /^((http|https):\/\/).*$/

    class << self
      attr_reader :pattern

      def match(url)
        !(url =~ pattern).nil?
      end

      def parse(response, opts = {})
        response.body
      end

      def browse_actions_for_html(browser, opts = {})
      end

      def use_browser
        false
      end
    end
  end
end

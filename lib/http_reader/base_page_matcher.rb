module HttpReader
  class BasePageMatcher
    @pattern = /^o2.pl$/i

    class << self
      attr_reader :pattern

      def match(url)
        !(url =~ pattern).nil?
      end
    end

    def read(body)
      body
    end

    private

    def pattern
      self.class.pattern
    end
  end
end
require 'nokogiri'

module HttpReader
  class HashPageParser < BasePageParser
    KEY_IDX        = 0
    SELECTOR_IDX   = 1
    TYPE_SEPARATOR = ';'

    @pattern = /^((http|https):\/\/).*$/

    def self.parse(response, opts = {})
      page = Nokogiri::HTML(response.body)
      hash = opts.inject({}) do |h, item|
        key, value = prepare_key_value(page, item)
        h[key]     = value
        h
      end
    end

    private

    def self.prepare_key_value(page, item)
      key                = item[KEY_IDX]
      selector, is_array = prepare_selector(item[SELECTOR_IDX])
      result = page.css(selector)
      value  = result.map(&:text)
      [key, is_array ? value : value.first]
    end

    def self.prepare_selector(value)
      selector, is_array = value.split(TYPE_SEPARATOR)
      [selector, is_array.to_s.downcase == 'array']
    end
  end
end

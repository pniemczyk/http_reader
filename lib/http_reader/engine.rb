require 'httparty'
require 'logger'
require 'watir-webdriver'
require 'headless'


module HttpReader
  class Engine
    ReadError       = Class.new(StandardError)
    DefaultResponse = Struct.new(:body, :code, :message, :headers)
    attr_reader :parsers, :default_parser, :http_client, :browser, :logger

    def initialize(config = {})
      @parsers        = config.fetch(:parsers, [])
      @default_parser = config.fetch(:default_parser, HashPageParser)
      @http_client    = config.fetch(:http_client, HTTParty)
      @browser        = config.fetch(:browser, Watir::Browser)
      @logger         = config.fetch(:logger, Logger.new(STDOUT))
    end

    def read(url, opts = {})
      parser       = opts[:parser] || find_parser(url)
      response = if parser.use_browser
        browse_opts  = opts.fetch(:browse_opts, {})
        browse(url, parser, browse_opts)
      else
        request_opts = opts.fetch(:request_opts, {})
        request(url, request_opts)
      end

      parse_opts   = opts.fetch(:parse_opts, {})
      parser.parse(response, parse_opts)
    rescue => e
      log_error('read', e, "url: #{url}, opts: #{opts.to_json}")
      raise ReadError.new(e.message)
    end

    private

    def find_parser(url)
      parsers.each do |parser|
        return parser if parser.match(url)
      end

      default_parser
    end

    def browse(url, parser, opts = {})
      html = nil
      headless.start
      b    = browser.start(url)
      html = parser.browse_actions_for_html(b, opts)
      b.close
      headless.destroy
      DefaultResponse.new(html, 200, opts[:message] || "success")
    rescue => e
      log_error('browse', e)
      DefaultResponse.new(html, 500, e.message)
    end

    def request(url, opts = {})
      method  = opts.fetch(:method, :get)
      options = opts.fetch(:options, {})
      http_client.public_send(method, url, options)
    rescue => e
      log_error('request', e)
      DefaultResponse.new(nil, 500, e.message)
    end

    def headless
      @headless ||= Headless.new
    end

    def log_error(method, ex, info = nil)
      logger.error("HttpReader::Engine##{method} - #{ex.message} #{info}")
    end
  end
end

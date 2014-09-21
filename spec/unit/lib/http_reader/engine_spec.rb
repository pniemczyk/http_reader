require 'spec_helper'


describe HttpReader::Engine do
  let(:default_parser) { double('default_parser') }
  let(:parsers)        { [] }
  let(:http_client)    { double('HTTParty') }
  let(:browser)        { double('Watir::Browser') }
  let(:logger)         { double('Logger') }
  let(:headless)       { double('Headless') }

  let(:init_opts) do
    {
      parsers: parsers,
      default_parser: default_parser,
      http_client: http_client,
      browser: browser,
      logger: logger
    }
  end

  let(:test_url)       { 'http://localhost/test' }
  let(:active_browser) { double('active_browser') }

  subject { described_class.new(init_opts) }
  context '#initialize' do
    context 'init #parsers' do
      context 'default' do
        let(:init_opts) { {} }
        it 'should eq []' do
          expect(subject.parsers).to eq []
        end
      end
      context 'optional' do
        it 'can be set as array of parsers' do
          expect(subject.parsers).to eq parsers
        end
      end
    end
    context 'init #default_parser' do
      context 'default' do
        let(:init_opts) { {} }
        it 'should eq HashPageParser' do
          expect(subject.default_parser).to eq HttpReader::HashPageParser
        end
      end
      context 'optional' do
        it 'can be set new default_parser' do
          expect(subject.default_parser).to eq default_parser
        end
      end
    end
    context 'init #http_client' do
      context 'default' do
        let(:init_opts) { {} }
        it 'should eq HTTParty' do
          expect(subject.http_client).to eq HTTParty
        end
      end
      context 'optional' do
        it 'can be set new http_client' do
          expect(subject.http_client).to eq http_client
        end
      end
    end
    context 'init #browser' do
      context 'default' do
        let(:init_opts) { {} }
        it 'should eq Watir::Browser' do
          expect(subject.browser).to eq Watir::Browser
        end
      end
      context 'optional' do
        it 'can be set new browser' do
          expect(subject.browser).to eq browser
        end
      end
    end
    context 'init #logger' do
      context 'default' do
        let(:init_opts) { {} }
        it 'should eq Logger' do
          expect(subject.logger).to be_a Logger
        end
      end
      context 'optional' do
        it 'can be set new browser' do
          expect(subject.logger).to eq logger
        end
      end
    end
  end

  context '#read' do
    context 'should use parser' do
      let(:parser_in_opts) { double('parser_in_opts') }
      let(:response)       { double('response', body: 'body')}
      it 'from provided opts' do
        expect(parser_in_opts).to receive(:use_browser).and_return(false)
        expect(http_client).to receive(:get)
                               .with(test_url, {})
                               .and_return(response)
        expect(parser_in_opts).to receive(:parse).with(response, {})
        subject.read(test_url, parser: parser_in_opts)
      end

      it 'default when no parsers are available' do
        expect(default_parser).to receive(:use_browser).and_return(false)
        expect(http_client).to receive(:get)
                               .with(test_url, {})
                               .and_return(response)
        expect(default_parser).to receive(:parse).with(response, {})
        subject.read(test_url)
      end

      context 'which' do
        let(:parser_one) { double('parser_one') }
        let(:parser_two) { double('parser_two') }
        let(:parsers)        { [parser_one, parser_two] }
        it 'match as first with url' do
          expect(parser_one).to receive(:match).with(test_url).and_return(false)
          expect(parser_two).to receive(:match).with(test_url).and_return(true)
          expect(parser_two).to receive(:use_browser).and_return(false)
          expect(http_client).to receive(:get)
                                 .with(test_url, {})
                                 .and_return(response)
          expect(parser_two).to receive(:parse).with(response, {})
          subject.read(test_url)
        end

        it 'is default_parser when no parser match' do
          expect(parser_one).to receive(:match).with(test_url).and_return(false)
          expect(parser_two).to receive(:match).with(test_url).and_return(false)
          expect(default_parser).to receive(:use_browser).and_return(false)
          expect(http_client).to receive(:get)
                                 .with(test_url, {})
                                 .and_return(response)
          expect(default_parser).to receive(:parse).with(response, {})
          subject.read(test_url)
        end
      end
    end

    it 'should provide parse_opts to #parser#parse method' do
      parse_opts =  { title: 'h1' }
      response   = double('response', body: 'body')
      expect(default_parser).to receive(:use_browser).and_return(false)
      expect(http_client).to receive(:get)
                             .with(test_url, {})
                             .and_return(response)
      expect(default_parser).to receive(:parse).with(response, parse_opts)
      subject.read(test_url, parse_opts: parse_opts)
    end

    it 'should provide request_opts to request method' do
      http_client_method = :post
      request_opts       = { method: http_client_method, options: { body: {token: '123'}}}
      response   = double('response', body: 'body')
      expect(default_parser).to receive(:use_browser).and_return(false)
      expect(http_client).to receive(http_client_method)
                             .with(test_url, request_opts[:options])
                             .and_return(response)
      expect(default_parser).to receive(:parse).with(response, {})
      subject.read(test_url, request_opts: request_opts)
    end

    it 'should provide browse_opts to request method' do
      message      = 'done'
      browse_opts  = { process: :continue, message: message}
      browser_body = "body"
      response = described_class::DefaultResponse.new(browser_body, 200, message)
      expect(Headless).to receive(:new).with(display: 100, reuse: true, destroy_at_exit: true).and_return(headless)
      expect(headless).to receive(:start)
      expect(default_parser).to receive(:use_browser).and_return(true)
      expect(browser).to receive(:new).and_return(active_browser)
      expect(active_browser).to receive(:goto).with(test_url)
      expect(default_parser).to receive(:browse_actions_for_html)
                                .with(active_browser, browse_opts)
                                .and_return(browser_body)
      expect(default_parser).to receive(:parse).with(response, {})

      subject.read(test_url, browse_opts: browse_opts)
    end

    it 'should close browser and destroy headless after browse' do
      message      = 'done'
      browse_opts  = { process: :continue, message: message}
      browser_body = "body"
      response = described_class::DefaultResponse.new(browser_body, 200, message)
      expect(Headless).to receive(:new).with(display: 100, reuse: true, destroy_at_exit: true).and_return(headless)
      expect(headless).to receive(:start)
      expect(default_parser).to receive(:use_browser).and_return(true)
      expect(browser).to receive(:new).and_return(active_browser)
      expect(active_browser).to receive(:goto).with(test_url)
      expect(default_parser).to receive(:browse_actions_for_html)
                                .with(active_browser, browse_opts)
                                .and_return(browser_body)
      expect(default_parser).to receive(:parse).with(response, {})
      subject.instance_variable_set(:@browser_keep_running,false)
      expect(active_browser).to receive(:close)
      expect(headless).to receive(:destroy)
      subject.read(test_url, browse_opts: browse_opts)
    end

    context 'on raise errors' do

      it 'raise ReadError' do
        error_msg = 'HttpReader::Engine#read - Bad url: http://localhost/test, opts: {}'
        expect(default_parser).to receive(:use_browser).and_raise('Bad')
        expect(logger).to receive(:error).with(error_msg)
        expect { subject.read(test_url) }.to raise_error(described_class::ReadError, 'Bad')
      end

      it 'in #request' do
        error_msg = 'HttpReader::Engine#request - Bad '
        response  = described_class::DefaultResponse.new(nil, 500, 'Bad')
        expect(default_parser).to receive(:use_browser).and_return(false)
        expect(http_client).to receive(:get).with(test_url, {}).and_raise('Bad')
        expect(default_parser).to receive(:parse).with(response, {})
        expect(logger).to receive(:error).with(error_msg)
        subject.read(test_url)
      end

      it 'in #browse' do
        error_msg = 'HttpReader::Engine#browse - Bad '
        response  = described_class::DefaultResponse.new(nil, 500, 'Bad')
        expect(default_parser).to receive(:use_browser).and_return(true)
        expect(browser).to receive(:new).and_raise('Bad')
        expect(default_parser).to receive(:parse).with(response, {})
        expect(logger).to receive(:error).with(error_msg)
        subject.read(test_url)
      end
    end
  end
end

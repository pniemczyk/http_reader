# HttpReader
[![Gem Version](https://badge.fury.io/rb/http_reader.svg)](http://badge.fury.io/rb/http_reader)
[![Build Status](https://secure.travis-ci.org/pniemczyk/http_reader.png?branch=master)](https://travis-ci.org/pniemczyk/http_reader) 
[![Dependency Status](https://gemnasium.com/pniemczyk/http_reader.png)](https://gemnasium.com/pniemczyk/http_reader)
[![Code Climate](https://codeclimate.com/github/pniemczyk/http_reader/badges/gpa.svg)](https://codeclimate.com/github/pniemczyk/http_reader)

Read any document on internet and parse to your own format :D

## Installation

Add this line to your application's Gemfile:

    gem 'http_reader'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http_reader

## Usage

    engine = HttpReader::Engine.new(opts)
    engine.read('http://www.google.com')

### Available opts [Hash]
- **parsers:** list of document parser Classes [ default: [] ]
- **default_parser:** parser used when none parser was match for url [default: HashPageParser]
- **http_client:** http_client for downloading pages sources, [default: HTTParty]
- **browser:** browser_client to processing and download source, [default: Watir::Browser]
- **logger:** default: Logger

## Examples

### Usage default_parser as HashPageParser

    engine = HttpReader::Engine.new
    read_opts = {title: 'h1', items: '.content li;array'}
    engine.read('http://example.org', read_opts)

**Where page body is:**

    <h1>Information</h1>
    <p>not importante</p>
    <div class="content">
        Items: <ul><li>A</li><li>B</li><li>C</li></ul>
    </div>

**Result should be:**

    {:title=>"Information", :items=>%w{A B C}}


### Usage own Parser class 

**Class body:**

    Class TestParser < BasePageParser
      @pattern = /^((http|https):\/\/www.google.com)$/
      class << self
        def browse_actions_for_html(browser, opts = {})
          div  = browser.div(id: 'als')
          raise 'Cannot find div' unless div.exists?
          div.html
        end

        def parse(response, opts = {})
          n_body = Nokogiri::HTML(response.body)
          { text: n_body.css('p').text }
        end

        def use_browser
          true
        end
      end
    end

**initializtion:**

    engine = HttpReader::Engine.new(default_parser: TestParser)
    engine.read('http://www.google.com')

**Or**

    engine = HttpReader::Engine.new(parsers: [TestParser])
    engine.read('http://www.google.com')

**Or**

    engine = HttpReader::Engine.new
    engine.read('http://www.google.com', parser: TestParser)



## More info about syntax
- [watir-webdriver](https://github.com/watir/watir-webdriver)
- [nokogiri](http://ruby.bastardsbook.com/chapters/html-parsing/)

## Dependecies
### Gems
- nokogiri
- httparty
- headless
- watir-webdriver

### System components
- xvfb
*instalation on ubuntu: sudo apt-get install xvfb*


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
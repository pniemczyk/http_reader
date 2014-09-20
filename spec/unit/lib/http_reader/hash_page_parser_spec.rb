require 'spec_helper'

describe HttpReader::HashPageParser do
  subject { described_class }

  let(:pattern) { /^((http|https):\/\/).*$/ }

  context 'self' do
    it '#pattern cover every url' do
      expect(subject.pattern).to eq pattern
    end

    context '#match' do
      it 'returns true for url string' do
        expect(subject.match('http://some_url')).to eq true
      end

      it 'returns false for non url string' do
        expect(subject.match('some_fake_url')).to eq false
      end
    end

    context '#parse' do
      let(:body)     { '<h1>Information</h1><p>not importante</p><div class="content">Items: <ul><li>A</li><li>B</li><li>C</li></ul></div>' }
      let(:opts)     { {title: 'h1', items: '.content li;array'} }
      let(:response) { double('response', body: body) }
      let(:result)   { {:title=>"Information", :items=>%w{A B C}} }
      it 'returns body' do
        expect(subject.parse(response, opts)).to eq result
      end
    end
  end
end

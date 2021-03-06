require 'spec_helper'

describe HttpReader::BasePageParser do
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
      let(:body) { 'test_body' }
      let(:response) { double('response', body: body) }
      it 'returns body' do
        expect(subject.parse(response)).to eq body
      end
    end
  end
end

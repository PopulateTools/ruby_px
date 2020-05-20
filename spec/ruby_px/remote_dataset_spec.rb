# frozen_string_literal: true

require 'spec_helper'

describe RubyPx::Dataset do
  let(:subject) { described_class.new 'http://populate-data.s3.amazonaws.com/ruby_px/f1.px' }

  describe '#headings' do
    it 'should return the list of headings described in the file' do
      expect(subject.headings).to eq(['Fenómeno demográfico'])
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe RubyPx::Dataset::Data do

  let(:subject) { described_class.new }

  describe '#concat and #at' do
    it 'should store the values and return them ' do
      subject.concat (0..12000).to_a
      subject.concat (12001..32000).to_a

      expect(subject.at(12)).to eq 12
      expect(subject.at(3475)).to eq 3475
      expect(subject.at(14223)).to eq 14223
      expect(subject.at(23987)).to eq 23987
    end
  end
end

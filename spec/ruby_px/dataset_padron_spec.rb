# frozen_string_literal: true

require 'spec_helper'

describe RubyPx::Dataset do
  let(:subject) { described_class.new 'spec/fixtures/ine-padron-2014.px' }

  context "ine-padron-2014.px" do
    describe '#headings' do
      it 'should return the list of headings described in the file' do
        expect(subject.headings).to eq(['edad (año a año)'])
      end
    end

    describe '#stubs' do
      it 'should return the list of stubs described in the file' do
        expect(subject.stubs).to eq(%w[sexo municipios])
      end
    end

    describe 'metadata methods' do
      it 'should return the title' do
        expect(subject.title).to eq('Población por sexo, municipios y edad (año a año).')
      end

      it 'should return the units' do
        expect(subject.units).to eq('personas')
      end

      it 'should return the source' do
        expect(subject.source).to eq('Instituto Nacional de Estadística')
      end

      it 'should return the contact' do
        expect(subject.contact).to eq('INE E-mail:www.ine.es/infoine. Internet: www.ine.es. Tel: +34 91 583 91 00 Fax: +34 91 583 91 58')
      end

      it 'should return the last_updated' do
        expect(subject.last_updated).to eq('05/10/99')
      end

      it 'should return the creation_date' do
        expect(subject.creation_date).to eq('20141201')
      end
    end

    describe '#dimension' do
      it 'should return all the values of a dimension' do
        expect(subject.dimension('edad (año a año)')).to include('Total')
        expect(subject.dimension('edad (año a año)')).to include('100 y más')
      end

      it 'should return the number of values' do
        expect(subject.dimension('edad (año a año)').length).to eq(102)
      end

      it 'should return an error if the dimension does not exist' do
        expect do
          subject.dimension('foo').values
        end.to raise_error('Missing dimension foo')
      end
    end

    describe '#dimensions' do
      it 'should return an array with all the dimensions of the dataset' do
        expect(subject.dimensions).to eq(['sexo', 'edad (año a año)', 'municipios'])
      end
    end

    describe '#data' do
      it 'should raise an error if a dimension value does not exist' do
        expect do
          subject.data('edad (año a año)' => 'Totalxxx', 'sexo' => 'Ambos sexos', 'municipios' => '28079-Madrid')
        end.to raise_error('Invalid value Totalxxx for dimension edad (año a año)')
      end

      it 'should raise an error if a dimension does not exist' do
        expect do
          subject.data('foo' => 'Total', 'sexo' => 'Ambos sexos', 'municipios' => '28079-Madrid')
        end.to raise_error('Missing dimension foo')
      end

      it 'should return data when all the dimensions are provided' do
        expect(subject.data('edad (año a año)' => 'Total', 'sexo' => 'Ambos sexos', 'municipios' => '28079-Madrid')).to eq('3165235')
        expect(subject.data('edad (año a año)' => 'Total', 'sexo' => 'Hombres', 'municipios' => '28079-Madrid')).to eq('1472990')
        expect(subject.data('edad (año a año)' => 'Total', 'sexo' => 'Mujeres', 'municipios' => '28079-Madrid')).to eq('1692245')
      end

      it 'should return an array of data when all the dimensions are provided except 1' do
        result = subject.data('edad (año a año)' => 'Total', 'sexo' => 'Ambos sexos')
        expect(result.first).to eq('46771341')
        expect(result[3899]).to eq('3165235')
        expect(result.length).to eq(8118)
      end

      it 'should return an error if more than one dimension is expected in the result' do
        expect do
          subject.data('edad (año a año)' => 'Total')
        end.to raise_error('Not implented yet, sorry')
      end
    end
  end
end

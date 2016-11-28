require 'spec_helper'

describe RubyPx::Dataset do
  let(:subject) { described_class.new 'spec/fixtures/ine-fenomenos-demograficos-2014-alava-23001.px' }

  describe '#headings' do
    it 'should return the list of headings described in the file' do
      expect(subject.headings).to eq(['Fenómeno demográfico','Periodo'])
    end
  end

  describe '#stubs' do
    it 'should return the list of stubs described in the file' do
      expect(subject.stubs).to eq(['Municipios'])
    end
  end

  describe 'metadata methods' do
    it 'should return the title' do
      expect(subject.title).to eq("Araba/Álava por municipios y fenómeno demográfico .")
    end

    it 'should return the units' do
      expect(subject.units).to eq("fenómenos demográficos")
    end

    it 'should return the source' do
      expect(subject.source).to eq("Instituto Nacional de Estadística")
    end

    it 'should return the creation_date' do
      expect(subject.creation_date).to eq("20161124")
    end
  end

  describe '#dimension' do
    it 'should return all the values of a dimension' do
      expect(subject.dimension('Fenómeno demográfico')).to include("nacidos vivos por residencia materna")
      expect(subject.dimension('Fenómeno demográfico')).to include("fallecidos por el lugar de residencia")
      expect(subject.dimension('Fenómeno demográfico')).to include("crecimiento vegetativo")

      expect(subject.dimension('Periodo')).to eq ['periodopx']
    end

    it 'should return the number of values' do
      expect(subject.dimension('Fenómeno demográfico').length).to eq(5)
      expect(subject.dimension('Periodo').length).to eq(1)
      expect(subject.dimension('Municipios').length).to eq(51)
    end

    it 'should return an error if the dimension does not exist' do
      expect {
        subject.dimension('foo').values
      }.to raise_error('Missing dimension foo')
    end
  end

  describe '#dimensions' do
    it 'should return an array with all the dimensions of the dataset' do
      expect(subject.dimensions).to eq(["Municipios", "Fenómeno demográfico", "Periodo"])
    end
  end

  describe '#data' do
    it 'should raise an error if a dimension value does not exist' do
      expect {
        subject.data('Fenómeno demográfico' => 'nacidos', 'Periodo' => 'periodopx', 'Municipios' => '01030 Lagrán')
      }.to raise_error("Invalid value nacidos for dimension Fenómeno demográfico")
    end

    it 'should raise an error if a dimension does not exist' do
      expect {
        subject.data('foo' => 'Total', 'Periodo' => 'periodopx', 'Municipios' => '01030 Lagrán')
      }.to raise_error('Missing dimension foo')
    end

    it 'should return data when all the dimensions are provided' do
      expect(subject.data('Fenómeno demográfico' => 'nacidos vivos por residencia materna', 'Periodo' => 'periodopx', 'Municipios' => '01030 Lagrán')).to eq('1.0')
      expect(subject.data('Fenómeno demográfico' => 'muertes fetales tardías por residencia materna', 'Periodo' => 'periodopx', 'Municipios' => '01030 Lagrán')).to eq('0.0')
      expect(subject.data('Fenómeno demográfico' => 'matrimonios por el lugar en que han fijado residencia', 'Periodo' => 'periodopx', 'Municipios' => '01030 Lagrán')).to eq('2.0')
      expect(subject.data('Fenómeno demográfico' => 'fallecidos por el lugar de residencia', 'Periodo' => 'periodopx', 'Municipios' => '01030 Lagrán')).to eq('4.0')
      expect(subject.data('Fenómeno demográfico' => 'crecimiento vegetativo', 'Periodo' => 'periodopx', 'Municipios' => '01030 Lagrán')).to eq('-3.0')

      expect(subject.data('Fenómeno demográfico' => 'nacidos vivos por residencia materna', 'Periodo' => 'periodopx', 'Municipios' => '01063 Zuia')).to eq('11.0')
      expect(subject.data('Fenómeno demográfico' => 'muertes fetales tardías por residencia materna', 'Periodo' => 'periodopx', 'Municipios' => '01063 Zuia')).to eq('0.0')
      expect(subject.data('Fenómeno demográfico' => 'matrimonios por el lugar en que han fijado residencia', 'Periodo' => 'periodopx', 'Municipios' => '01063 Zuia')).to eq('6.0')
      expect(subject.data('Fenómeno demográfico' => 'fallecidos por el lugar de residencia', 'Periodo' => 'periodopx', 'Municipios' => '01063 Zuia')).to eq('18.0')
      expect(subject.data('Fenómeno demográfico' => 'crecimiento vegetativo', 'Periodo' => 'periodopx', 'Municipios' => '01063 Zuia')).to eq('-7.0')
    end

    it 'should return an array of data when all the dimensions are provided except 1' do
      result = subject.data("Periodo"=>"periodopx", "Fenómeno demográfico"=>"nacidos vivos por residencia materna")
      expect(result.first).to eq('42.0')
      expect(result.last).to eq('11.0')
      expect(result.length).to eq(51)
    end

    it 'should return an error if more than one dimension is expected in the result' do
      expect {
        subject.data('Fenómeno demográfico' => 'crecimiento vegetativo')
      }.to raise_error("Not implented yet, sorry")
    end
  end
end

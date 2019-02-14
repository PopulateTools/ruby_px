require "open-uri"

module RubyPx
  class Dataset
    attr_reader :headings, :stubs

    METADATA_RECORDS = ['TITLE','UNITS','SOURCE','CONTACT','LAST-UPDATED','CREATION-DATE']
    HEADING_RECORD = 'HEADING'
    STUB_RECORD = 'STUB'

    def initialize(resource_uri)
      @metadata = {}
      @headings = []
      @stubs = []
      @values = {}
      @data = []

      parse_resource(resource_uri)
    end

    def title
      @metadata['TITLE']
    end

    def units
      @metadata['UNITS']
    end

    def source
      @metadata['SOURCE']
    end

    def contact
      @metadata['CONTACT']
    end

    def last_updated
      @metadata['LAST-UPDATED']
    end

    def creation_date
      @metadata['CREATION-DATE']
    end

    def dimension(name)
      @values[name] || raise("Missing dimension #{name}")
    end

    def dimensions
      @values.keys
    end

    def data(options)
      # Validate parameters
      options.each do |k,v|
        raise "Invalid value #{v} for dimension #{k}" unless dimension(k).include?(v)
      end

      # Return a single value
      # 2D array[ i*M + j]
      # 3D array[ i*(N*M) + j*M + k ]
      # 4D array[ i*(N*M*R) + j*M*R + k*R + l]
      if options.length == dimensions.length
        offset = 0

        # positions are i, j, k
        positions = (stubs + headings).map do |dimension_name|
          self.dimension(dimension_name).index(options[dimension_name])
        end

        # dimension_sizes are from all dimensions except the first one
        dimension_sizes = (stubs + headings)[1..-1].map do |dimension_name|
          self.dimension(dimension_name).length
        end

        positions.each_with_index do |p, i|
          d = dimension_sizes[i..-1].reduce(&:*)
          offset += (d ? p*d : p)
        end

        return @data[offset]

      # Return an array of options
      elsif options.length == dimensions.length - 1
        result = []

        missing_dimension = (dimensions - options.keys).first
        dimension(missing_dimension).each do |dimension_value|
          result << data(options.merge(missing_dimension => dimension_value))
        end

        return result
      else
        raise "Not implented yet, sorry"
      end
    end

    def inspect
      "#<#{self.class.name}:#{self.object_id}>"
    end

    private

    def parse_resource(resource_uri)
      open(resource_uri).each_line do |line|
        parse_line(line.chomp)
      end

      true
    end

    def parse_line(line)
      @line = line

      if @current_record.nil?
        key, value = line.scan(/[^\=]+/)
        set_current_record(key)
      else
        value = line
      end

      return if @current_record.nil? || value.nil?

      if @type == :data
        value = value.split(/[\ ;,\t]/).delete_if{ |s| s.blank? }.each(&:strip)

        add_value_to_bucket(bucket,value) unless value == [';']
      else
        # First format: "\"20141201\";"
        if value =~ /\A\"([^"]+)\";\z/
          value = value.match(/\A\"([^"]+)\";\z/)[1]
          add_value_to_bucket(bucket, value.strip)

          # Second format: "Ambos sexos","Hombres","Mujeres";
        elsif value =~ /\"([^"]+)\",?/
          value = value.split(/\"([^"]+)\",?;?/).delete_if{ |s| s.blank? }.each(&:strip)
          add_value_to_bucket(bucket, value)
        end
      end

      # If we see a ; at the end of the line, close out the record so we
      # expect a new record.
      if line[-1..-1] == ";"
        @current_record = nil
      end
    end

    def set_current_record(key)
      @current_record = if METADATA_RECORDS.include?(key)
                          @type = :metadata
                          key
                        elsif key == HEADING_RECORD
                          @type = :headings
                          key
                        elsif key == STUB_RECORD
                          @type = :stubs
                          key
                        elsif key =~ /\AVALUES/
                          @type = :values
                          key.match(/\"([^"]+)\"/)[1]
                        elsif key =~ /\ADATA/
                          @type = :data
                          key
                        end
    end

    def bucket
      instance_variable_get("@#{@type}")
    end

    def add_value_to_bucket(bucket, value)
      if @type == :data
        @data.concat(value)
      elsif @type == :headings || @type == :stubs
        bucket << value
        bucket.flatten!
      else
        if bucket.is_a?(Hash)
          if value.is_a?(Array)
            value = value.map(&:strip)
          elsif value.is_a?(String)
            value.strip!
          end
          if bucket[@current_record].nil?
            value = Array.wrap(value) if @type == :values
            bucket[@current_record] = value
          else
            bucket[@current_record].concat([value])
            bucket[@current_record].flatten!
          end
        end
      end
    end

  end
end

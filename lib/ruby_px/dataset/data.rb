module RubyPx
  class Dataset
    class Data

      CHUNK_SIZE = 5_000

      def initialize
        @current_chunk_index = 0
      end

      def at index
        chunk_index = index/CHUNK_SIZE
        index_inside_chunk = index%CHUNK_SIZE

        get_chunk(chunk_index)[index_inside_chunk]
      end

      def concat array
        current_chunk.concat(array)
        if current_chunk.size > CHUNK_SIZE
          excess = current_chunk.pop(current_chunk.size-CHUNK_SIZE)
          self.current_chunk_index += 1
          concat(excess)
        end
      end

      def indexes_count
        self.current_chunk_index+1
      end

      private

      attr_accessor :current_chunk_index

      def current_chunk
        current = instance_variable_get("@chunk_#{self.current_chunk_index}")
        return current if current

        instance_variable_set("@chunk_#{self.current_chunk_index}", [])
      end

      def get_chunk chunk_index
        instance_variable_get("@chunk_#{chunk_index}")
      end

    end
  end
end

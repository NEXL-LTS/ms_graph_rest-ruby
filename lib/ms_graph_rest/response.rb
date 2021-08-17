require 'camel_snake_struct'

module MsGraphRest
  class Response < CamelSnakeStruct
    include Enumerable

    def initialize(data)
      @data = data
      super(data)
    end

    def each
      value.each { |val| yield(val) }
    end

    def size
      value.size
    end

    def to_h
      to_hash
    end
  end
end


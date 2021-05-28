require 'camel_snake_struct'

module MsGraphRest
  class TodoLists
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
    end

    attr_reader :client, :query

    def initialize(client:, query: {})
      @client = client
      @query = query
    end

    def get(select: nil)
      Response.new(client.get("me/todo/lists", query.merge({ '$select' => select }.compact)))
    end
  end
end

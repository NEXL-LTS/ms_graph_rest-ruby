require 'camel_snake_struct'

module MsGraphRest
  class TodoListTasks

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

    attr_reader :todo_list, :client, :query

    def initialize(todo_list, client:, query: {})
      @todo_list = todo_list
      @client = client
      @query = query
    end

    def get(select: nil)
      Response.new(client.get("me/todo/lists/#{todo_list}/tasks", query.merge({ '$select' => select }.compact)))
    end

  end
end

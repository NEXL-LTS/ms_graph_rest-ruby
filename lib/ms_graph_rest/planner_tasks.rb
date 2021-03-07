require 'camel_snake_struct'

module MsGraphRest
  class PlannerTasks
    class Response < CamelSnakeStruct
      include Enumerable

      def initialize(data)
        @data = data
        super(data)
      end

      def each
        value.each { |val| yield(val) }
      end

      def next_get_query
        return nil unless odata_next_link

        uri = URI.parse(odata_next_link)
        params = CGI.parse(uri.query)
        { select: params["$select"]&.first }.compact
      end

      def size
        value.size
      end

      def to_h
        to_hash
      end
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    attr_reader :client, :query, :path

    def initialize(path, client:, query: {})
      @client = client
      @query = query
      @path = path
    end

    def get(select: nil)
      Response.new(client.get(path, query.merge({'$select' => select}.compact)))
    end

    def fetch(id)
      task = client.get("planner/tasks/#{id}", {})
      Response.new(task)
    end

    def select(val)
      val = val.map(&:to_s).map { |v| v.camelize(:lower) }.join(',') if val.is_a?(Array)
      new_with_query(query.merge('$select' => val))
    end

    private

    def new_with_query(query)
      self.class.new(path, client: client, query: query)
    end
  end
end

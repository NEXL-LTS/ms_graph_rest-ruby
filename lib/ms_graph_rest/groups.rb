require 'camel_snake_struct'

module MsGraphRest
  class Groups
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

    attr_reader :client, :query

    def initialize(client:, query: {})
      @client = client
      @query = query
    end

    def get(select: nil, filter: nil, count: nil, top: nil, skip: nil, order_by: nil, search: nil)
      Response.new(client.get("groups", query.merge({ '$skip' => skip,
                                                      '$search' => search,
                                                      '$select' => select,
                                                      '$filter' => filter,
                                                      '$top' => top,
                                                      '$orderBy' => order_by,
                                                      '$count' => count }.compact)))
    end

    def select(val)
      val = val.map(&:to_s).map { |v| v.camelize(:lower) }.join(',') if val.is_a?(Array)
      new_with_query(query.merge('$select' => val))
    end

    def filter(val)
      new_with_query(query.merge('$filter' => val))
    end

    def count
      client.get("groups/$count", query.compact)
    end

    def order_by(val)
      new_with_query(query.merge('$orderBy' => val))
    end

    def search(val)
      new_with_query(query.merge('$search' => val))
    end

    private

    def new_with_query(query)
      self.class.new(client: client, query: query)
    end
  end
end

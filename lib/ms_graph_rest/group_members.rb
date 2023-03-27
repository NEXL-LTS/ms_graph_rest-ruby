require 'camel_snake_struct'

module MsGraphRest
  class GroupMembers
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
        _extract_query_params(params)
      end

      def size
        value.size
      end

      private

      def _extract_query_params(params)
        { select: params["$select"]&.first, search: params["$search"]&.first,
          count: params["$count"]&.first, skip: params["$skip"]&.first,
          filter: params["$filter"]&.first, order_by: params["$orderBy"]&.first,
          top: params["$top"]&.first, skiptoken: params["$skiptoken"]&.first }.compact
      end
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    attr_reader :client, :group_id, :query

    def initialize(client:, group_id:, query: {})
      @client = client
      @query = query
      @group_id = group_id
    end

    def get(select: nil, filter: nil, count: nil, top: nil,
            skip: nil, order_by: nil, search: nil, skiptoken: nil)
      Response.new(client.get("groups/#{group_id}/members", query.merge({ '$skip' => skip,
                                                                          '$search' => search,
                                                                          '$select' => select,
                                                                          '$filter' => filter,
                                                                          '$top' => top,
                                                                          '$orderBy' => order_by,
                                                                          '$count' => count,
                                                                          '$skiptoken' => skiptoken }.compact)))
    end

    private

    def new_with_query(query)
      self.class.new(client: client,
                     query: query)
    end
  end
end

require_relative 'chainable_action'
require_relative 'response_with_pagination'

module MsGraphRest
  class Places < ChainableAction
    class Response < ResponseWithPagination
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    # @param path [String]  either microsoft.graph.room or microsoft.graph.roomlist
    def get(path: 'microsoft.graph.room')
      raise ArgumentError unless path.in?(['microsoft.graph.room', 'microsoft.graph.roomlist'])

      Response.new(client.get("places/#{path}", query))
    end
  end
end

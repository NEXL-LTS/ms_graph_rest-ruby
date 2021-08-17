require 'camel_snake_struct'

module MsGraphRest
  class CalendarGroups < ChainableAction
    class Response < ResponseWithPagination
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    attr_reader :client, :path, :query

    def initialize(client:, query: {})
      @client = client
      @query = query
    end

    def get(user_id:)
      path = user_id ? "users/#{user_id}/calendarGroups" : "me/calendarGroups"
      Response.new(client.get(path, {}))
    end
  end
end


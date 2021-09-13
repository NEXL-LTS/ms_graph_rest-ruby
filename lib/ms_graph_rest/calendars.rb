require 'camel_snake_struct'

module MsGraphRest
  class Calendars < ChainableAction
    class Response < ResponseWithPagination
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    attr_reader :client, :path, :query

    # rubocop:disable Lint/MissingSuper
    def initialize(client:, query: {})
      @client = client
      @query = query
    end
    # rubocop:enable Lint/MissingSuper

    def get(user_id: nil, calendar_group: nil)
      path =
        case [user_id.nil?, calendar_group.nil?]
        when [true, true] then "me/calendars"
        when [false, true] then "users/#{user_id}/calendars"
        when [true, false] then "me/calendarGroups/#{calendar_group}/calendars"
        when [false, false] then "users/#{user_id}/calendarGroups/#{calendar_group}/calendars"
        end

      Response.new(client.get(path, {}))
    end
  end
end

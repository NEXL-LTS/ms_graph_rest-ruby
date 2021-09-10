require 'camel_snake_struct'

module MsGraphRest
  class CalendarView < ChainableAction
    class Response < ResponseWithPagination
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    attr_reader :client, :path, :query

    def initialize(client:, query: {})
      @client = client
      @query = query
    end

    def get(start_date_time:, end_date_time:, skip: nil, top: nil, select: nil, user_id: nil)
      start_date_time = start_date_time.iso8601 if start_date_time.respond_to?(:iso8601)
      end_date_time = end_date_time.iso8601 if end_date_time.respond_to?(:iso8601)
      path = user_id ? "users/#{user_id}/calendar/calendarView" : "me/calendar/calendarView"

      query['startDateTime'] = start_date_time
      query['endDateTime'] = end_date_time

      Response.new(client.get(path, query))
    end
  end
end

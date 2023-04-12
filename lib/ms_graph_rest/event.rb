module MsGraphRest
  class Response < CamelSnakeStruct
  end

  class Event
    attr_reader :client, :path, :query

    def initialize(path, client:, query: {})
      @path = path
      @client = client
      @query = query
    end

    def get(id, select: nil)
      get_path = "#{path}/events/#{id}"
      Response.new(client.get(get_path, query.merge({ '$select' => select }.compact)))
    end

    # 60 Seconds * 60 Minutes * 24 hours * 7 days * 8 weeks
    EIGHT_WEEKS = 60 * 60 * 24 * 7 * 8
    def get_instances(id, select: nil, start_date_time: Time.now, end_date_time: Time.now + EIGHT_WEEKS)
      get_path = "#{path}/events/#{id}/instances"

      result = client.get(
        get_path,
        query.merge({
          '$select' => select, 'startDateTime' => start_date_time.utc.iso8601,
          'endDateTime' => end_date_time.utc.iso8601,
        }.compact)
      )
      CalendarView::Response.new(result)
    end
  end
end

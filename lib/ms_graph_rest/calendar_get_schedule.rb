require 'camel_snake_struct'
require_relative 'chainable_action'
require_relative 'response_with_pagination'

module MsGraphRest
  class CalendarGetSchedule < ChainableAction
    class Response < ResponseWithPagination
    end
    Response.example("value" => [], "@odata.context" => "", "@odata.nextLink" => "")

    # Issues getSchedule. If user_id is given, uses the
    #  /users/ID/calendar/getSchedule, otherwise me/calendar/getSchedule endpoint
    # @return Response
    # @param start_time [Time] Min Date Time
    # @param end_time [Time] Max Date Time
    # @param schedules [Array<String>] List of user mails to get schedules for
    # @param availability_view_interval [Integer]
    # @param user_id [String] Optional user id that is used for the request
    def get(start_time:, end_time:, schedules:, availability_view_interval: nil, user_id: nil)
      start_time = start_time.iso8601 if start_time.respond_to?(:iso8601)
      end_time = end_time.iso8601 if end_time.respond_to?(:iso8601)

      path = user_id ? "users/#{CGI.escape(user_id)}/calendar/getSchedule" : "me/calendar/getSchedule"

      body = {
        startTime: {
          dateTime: start_time,
          timeZone: 'UTC'
        },
        endTime: {
          dateTime: end_time,
          timeZone: 'UTC'
        },
        schedules: schedules,
        availabilityViewInterval: availability_view_interval
      }.compact

      Response.new(client.post(path + "?#{query.to_query}", body))
    end
  end
end

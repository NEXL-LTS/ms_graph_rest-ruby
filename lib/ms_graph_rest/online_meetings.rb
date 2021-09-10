require_relative 'chainable_action'
require_relative 'response_with_pagination'

module MsGraphRest
  class OnlineMeetings < ChainableAction
    class Response < ResponseWithPagination
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    def create(subject:, start_date_time:, end_date_time:, accept_language: "en", participants: nil, user_id: nil)
      start_date_time = start_date_time.iso8601 if start_date_time.respond_to?(:iso8601)
      end_date_time = end_date_time.iso8601 if end_date_time.respond_to?(:iso8601)

      body = {
        startDateTime: start_date_time,
        endDateTime: end_date_time,
        subject: subject,
        participants: participants
      }
      path = user_id ? "users/#{CGI.escape(user_id)}/onlineMeetings" : "me/onlineMeetings"
      headers = {
        "Accept-Language" => accept_language
      }
      Response.new(client.post(path, body, headers: headers))
    end

    # https://docs.microsoft.com/en-us/graph/api/onlinemeeting-update
    def update(id:, subject: nil, start_date_time: nil, end_date_time: nil, participants: nil, user_id: nil, accept_language: nil)
      start_date_time = start_date_time.iso8601 if start_date_time.respond_to?(:iso8601)
      end_date_time = end_date_time.iso8601 if end_date_time.respond_to?(:iso8601)

      body = {
        startDateTime: start_date_time,
        endDateTime: end_date_time,
        subject: subject,
        participants: participants
      }
      path = user_id ? "users/#{user_id}/onlineMeetings/#{id}" : "me/onlineMeetings/#{id}"
      headers = {
        "Accept-Language" => accept_language
      }.compact
      Response.new(client.patch(path, body, headers: headers))
    end

    def delete(id:, user_id: nil)
      # /me/onlineMeetings/{meetingId}
      # DELETE /users/{userId}/onlineMeetings/{meetingId}
      path = user_id ? "users/#{user_id}/onlineMeetings/#{id}" : "me/onlineMeetings/#{id}"

      client.delete(path)
    end
  end
end

module MsGraphRest
  class CalendarCancelEvent < ModifyingAction
    Response.example("value" => [], "@odata.context" => "", "@odata.nextLink" => "")

    # Issues getSchedule. If user_id is given, uses the
    #  /users/ID/calendar/getSchedule, otherwise me/calendar/getSchedule endpoint
    # @return Response
    # @param id [String] MSOffice Event ID
    # @param user_id [String] Optional user id that is used for the request
    def cancel(id:, user_id: nil, comment: nil)
      # POST /me/events/{id}/cancel
      # POST /users/{id | userPrincipalName}/events/{id}/cancel

      path = user_id ? "users/#{CGI.escape(user_id)}/events/#{id}/cancel" : "me/events/#{id}/cancel"
      body = { comment: comment }.compact

      client.post(path, body)
    end
  end
end

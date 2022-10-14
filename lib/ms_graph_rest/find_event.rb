module MsGraphRest
  class FindEvent < ChainableAction
    Response.example("value" => [], "@odata.context" => "", "@odata.nextLink" => "")

    def get(id:, user_id: nil)
      path = user_id ? "users/#{CGI.escape(user_id)}/events/#{id}" : "me/events/#{id}"
      Response.new(client.get(path, {}))
    end
  end
end

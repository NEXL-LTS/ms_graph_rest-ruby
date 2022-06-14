require_relative 'chainable_action'
require_relative 'response_with_pagination'

module MsGraphRest
  class FindRooms < ChainableAction
    class Response < ResponseWithPagination
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    # @param tenant_id [String] Optional tenant_id, if not given, uses the /me path
    # @param room_list [String] E-Mail address of the room list to filter on
    def get(tenant_id: nil, room_list: nil)
      path = tenant_id ? "users/#{CGI.escape(tenant_id)}/findRooms" : "me/findRooms"
      if room_list
        path += "(RoomList='#{CGI.escape(room_list)}')"
      end
      Response.new(client.get(path, query))
    end
  end
end

require_relative 'chainable_action'
require_relative 'response_with_pagination'

module MsGraphRest
  class Users < ChainableAction
    class Response < ResponseWithPagination
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    def get
      Response.new(client.get("users", query))
    end

    def count
      client.get("users/$count", query, consistencylevel: "eventual")
    end
  end
end

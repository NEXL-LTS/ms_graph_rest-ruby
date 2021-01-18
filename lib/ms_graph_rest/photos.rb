module MsGraphRest
  class Photos
    attr_reader :client

    def initialize(client:)
      @client = client
    end

    def get(user_principle_name)
      client.get_raw("users/#{user_principle_name}/photo/$value", {}).body
    end
  end
end
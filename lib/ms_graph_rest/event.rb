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
  end
end

module MsGraphRest
  class Response < CamelSnakeStruct
  end

  class Message
    attr_reader :client, :path, :query

    def initialize(path, client:, query: {})
      @path = path
      @client = client
      @query = query
    end

    def get(id_or_path, select: nil)
      get_path = id_or_path.to_s.include?('/') ? id_or_path : "#{path}/messages/#{id_or_path}"
      Response.new(client.get(get_path, query.merge({ '$select' => select }.compact)))
    end

    def select(val)
      val = val.map(&:to_s).map { |v| v.camelize(:lower) }.join(',') if val.is_a?(Array)
      new_with_query(query.merge('$select' => val))
    end

    private

    def new_with_query(query)
      self.class.new(path, client: client, query: query)
    end
  end
end

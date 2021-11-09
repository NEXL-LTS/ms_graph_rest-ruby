require 'camel_snake_struct'

module MsGraphRest
  class MessagesDelta
    class Response < CamelSnakeStruct
      def initialize(data)
        @data = data
        super(data)
      end

      def next_get_query
        return nil unless odata_next_link

        uri = URI.parse(odata_next_link)
        params = CGI.parse(uri.query)
        { skiptoken: params["$skiptoken"]&.first }.compact
      end

      def delta_query
        return nil unless odata_delta_link

        uri = URI.parse(odata_delta_link)
        params = CGI.parse(uri.query)
        { deltatoken: params["$deltatoken"]&.first }.compact
      end

      def to_h
        to_hash
      end
    end
    Response.example('value' => [{ "id" => "", "@removed" => { "reason" => "changed" } }],
                     "@odata.context" => "",
                     "@odata.nextLink" => "",
                     "@odata.deltaLink" => "")

    attr_reader :client, :path, :folder, :query

    def initialize(path, folder, client:, query: {})
      @path = "#{path.to_str}".gsub('//', '/')
      @folder = folder.to_s
      @path[0] = '' if @path.start_with?('/')
      @client = client
      @query = query
    end

    def get(select: nil, skiptoken: nil, deltatoken: nil, filter: nil, order_by: nil)
      Response.new(client.get("#{path}/mailFolders/#{folder}/messages/delta",
                              query.merge({ '$select' => select,
                                            '$skiptoken' => skiptoken,
                                            '$deltatoken' => deltatoken,
                                            '$filter' => filter,
                                            '$orderBy' => order_by }.compact)))
    end

    def select(val)
      val = val.map(&:to_s).map { |v| v.camelize(:lower) }.join(',') if val.is_a?(Array)
      new_with_query(query.merge('$select' => val))
    end

    def received_after(val)
      filter("receivedDateTime gt #{val}")
    end

    def filter(val)
      new_with_query(query.merge('$filter' => val))
    end

    def order_by(val)
      new_with_query(query.merge('$orderBy' => val))
    end

    private

    def new_with_query(query)
      self.class.new(path, folder, client: client, query: query)
    end
  end
end

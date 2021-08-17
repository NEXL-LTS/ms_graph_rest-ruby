require 'camel_snake_struct'

module MsGraphRest
  class ResponseWithPagination < CamelSnakeStruct
    include Enumerable

    def initialize(data)
      @data = data
      super(data)
    end

    def each
      value.each { |val| yield(val) }
    end

    def next_get_query
      return nil unless odata_next_link

      uri = URI.parse(odata_next_link)
      params = CGI.parse(uri.query)
      {
        skip: params["$skip"]&.first,
        skiptoken: params["$skiptoken"]&.first,
        top: params["$top"]&.first,
        select: params["$select"]&.first
      }.compact
    end

    def merge_with_next_page(response)
      new_data = response.to_hash
      new_data['value'] = to_hash['value'] + new_data['value']
      self.class.new(new_data)
    end

    def size
      value.size
    end

    def to_h
      to_hash
    end
  end
end

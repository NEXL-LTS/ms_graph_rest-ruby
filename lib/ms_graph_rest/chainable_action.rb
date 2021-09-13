require "active_support/core_ext/hash/indifferent_access"

module MsGraphRest
  class ChainableAction
    attr_reader :client, :query

    def initialize(client:, query: {})
      @client = client
      @query = query.with_indifferent_access
    end

    def get()
      raise NotImplementedError
    end

    # Auto paginates until no odata_next_link is left any more. Use with caution
    # Uses .get underhood
    # @param **args
    def all(**args)
      out = nil
      each_page(**args) do |response|
        if out
          out = out.merge_with_next_page(response)
        else
          out = response
        end
      end
      out
    end

    # Auto paginates until no odata_next_link is left any more. Use with caution
    # Uses .get underhood
    # @param **args
    # @yield ResponseWithPagination
    def each_page(**args)
      loop do
        response = get(**args)
        yield(response)

        break if response.odata_next_link.nil?

        parameters = Rack::Utils.parse_nested_query(URI(response.odata_next_link).query)
        parameters.each do |key, value|
          query[key] = value
        end
      end
    end

    def select(val)
      val = val.map(&:to_s).map { |v| v.camelize(:lower) }.join(',') if val.is_a?(Array)
      new_with_query(query.merge("$select": val))
    end

    def top(val)
      new_with_query(query.merge("$top": val))
    end

    def skip(val)
      new_with_query(query.merge("$skip": val))
    end

    def skiptoken(val)
      new_with_query(query.merge("$skiptoken": val))
    end

    def filter(val)
      new_with_query(query.merge("$filter": val))
    end

    private

    def new_with_query(query)
      self.class.new(client: client, query: query)
    end
  end
end

require 'active_support/core_ext/string'

require_relative 'hash_accessor'

module MsGraphRest
  class CalendarView
    class Response < HashAccessor
      include Enumerable

      def initialize(data)
        @data = data
        super(data)
      end

      def each
        value.each { |val| yield(val) }
      end

      def size
        value.size
      end
    end

    attr_reader :client, :path, :query

    def initialize(path, client:, query: {})
      @path = "#{path.to_str}".gsub('//', '/')
      @path[0] = '' if @path.start_with?('/')
      @client = client
      @query = query
    end

    def get(start_date_time:, end_date_time:)
      start_date_time = start_date_time.iso8601 if start_date_time.respond_to?(:iso8601)
      end_date_time = end_date_time.iso8601 if end_date_time.respond_to?(:iso8601)
      Response.new(client.get("#{path}/calendarView",
                              query.merge(startDateTime: start_date_time, endDateTime: end_date_time)))
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

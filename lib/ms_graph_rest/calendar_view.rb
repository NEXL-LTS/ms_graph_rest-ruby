require 'camel_snake_struct'

module MsGraphRest
  class CalendarView
    class Response < CamelSnakeStruct
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
        { start_date_time: params["startDateTime"]&.first,
          end_date_time: params["endDateTime"]&.first,
          skip: params["$skip"]&.first,
          top: params["$top"]&.first }
      end

      def size
        value.size
      end

      def to_h
        to_hash
      end
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")

    attr_reader :client, :path, :query

    def initialize(path, client:, query: {})
      @path = "#{path.to_str}".gsub('//', '/')
      @path[0] = '' if @path.start_with?('/')
      @client = client
      @query = query
    end

    def get(start_date_time:, end_date_time:, skip: nil, top: nil)
      start_date_time = start_date_time.iso8601 if start_date_time.respond_to?(:iso8601)
      end_date_time = end_date_time.iso8601 if end_date_time.respond_to?(:iso8601)

      Response.new(client.get("#{path}/calendarView",
                              query.merge({ 'startDateTime' => start_date_time,
                                            'endDateTime' => end_date_time,
                                            '$skip' => skip,
                                            '$top' => top }.compact)))
    end

    def create(options)
      Response.new(client.post("#{path}", options))
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

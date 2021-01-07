require 'active_support/core_ext/string'

module MsGraphRest
  class EmailDetails < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess

    property :address
    property :name
  end

  class EventResponseStatus < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared

    property :response
    property :time
  end

  class EventBody < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared

    property :content
    property :content_type, from: :contentType
  end

  class EventTime < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::Coercion

    property :date_time, from: :dateTime
    property :time_zone, from: :timeZone
  end

  class EventAttendeeStatus < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared

    property :response
    property :time
  end

  class EventAttendee < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::Coercion

    property :type
    property :status
    property :email_address, from: :emailAddress

    coerce_key :status, EventAttendeeStatus
    coerce_key :email_address, EmailDetails
  end

  class EventOrganizer < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::Coercion

    property :email_address, from: :emailAddress

    coerce_key :email_address, EmailDetails
  end

  class EventLocation < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::Coercion

    property :display_name, from: :displayName
    property :location_type, from: :locationType
    property :unique_id, from: :uniqueId
    property :unique_id_type, from: :uniqueIdType
  end

  class Event < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::Coercion

    property :id
    property :original_start_time_zone, from: :originalStartTimeZone
    property :original_end_time_zone, from: :originalEndTimeZone
    property :ical_uid, from: :iCalUId
    property :reminder_minutes_before_start, from: :reminderMinutesBeforeStart
    property :is_reminder_on, from: :isReminderOn
    property :response_status, from: :responseStatus
    property :odata_etag, from: "@odata.etag"
    property :subject
    property :body_preview, from: :bodyPreview
    property :body
    property :start
    property :end
    property :location
    property :attendees
    property :organizer

    coerce_key :response_status, EventResponseStatus
    coerce_key :body, EventBody
    coerce_key :start, EventTime
    coerce_key :end, EventTime
    coerce_key :location, EventLocation
    coerce_key :attendees, Array[EventAttendee]
    coerce_key :organizer, EventOrganizer
  end

  class CalendarView
    class Response
      include Enumerable

      def initialize(data)
        @data = data
      end

      def each
        value.each do |val|
          yield(Event.new(val))
        end
      end

      def size
        value.size
      end

      def odata
        start_txt = '@odata.'
        @data.each_with_object(OpenStruct.new) do |pair, data|
          key, val = pair
          if key.start_with?(start_txt)
            data[key.gsub(start_txt, '')] = val
          end
        end.freeze
      end

      private

      def value
        @data.fetch('value')
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

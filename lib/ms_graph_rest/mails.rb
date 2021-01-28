module MsGraphRest
  class Profile < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess

    property :email, from: :address
    property :name
  end

  class Mails
    class Response < Hashie::Trash
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::IgnoreUndeclared
      include Hashie::Extensions::Coercion

      property :message_id, from: :id
      property :conversation_id, from: :conversationId
      property :recipients, from: :toRecipients, with: ->(to_recipients) {
        to_recipients.map { |recipient| Profile.new(recipient.dig("emailAddress")) }.compact
      }
      property :sender, transform_with: ->(value) { Profile.new(value.dig("emailAddress")) }
      property :sent_at, from: :sentDateTime, with: ->(sent_date_time) { sent_date_time && Time.parse(sent_date_time) }
      property :payload
      property :internet_message_id, from: :internetMessageId

      def self.build(mail)
        Response.new(mail).tap { |response|
          response.payload = mail
        }
      end
    end

    attr_reader :client

    def initialize(client:)
      @client = client
    end

    def get(path)
      mail = client.get(path, {})
      Response.build(mail)
    end

    def get_all(path, start_time, page_size = 10)
      query_params = params(start_time, page_size)
      response = client.get(path, query_params)
      response["value"].each { |mail| yield Response.build(mail) }
      next_link = response["@odata.nextLink"]

      while (next_link)
        response = client.get(next_link, {})
        response["value"].each { |mail|  yield Response.build(mail) }
        next_link = response["@odata.nextLink"]
      end
    end

    private

    def params(start_time, page_size)
      {
        "$filter" => "sentDateTime ge #{start_time.iso8601}",
        "$orderBy" => "sentDateTime asc",
        "$top" => page_size,
        "$count" => "true"
      }
    end
  end
end

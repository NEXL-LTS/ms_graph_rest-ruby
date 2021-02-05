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
      property :to_recipients, from: :toRecipients, with: ->(to_recipients) {
        to_recipients.map { |recipient| Profile.new(recipient.dig("emailAddress")) }.compact
      }
      property :cc_recipients, from: :ccRecipients, with: ->(cc_recipients) {
        cc_recipients.map { |recipient| Profile.new(recipient.dig("emailAddress")) }.compact
      }
      property :sender, transform_with: ->(value) { Profile.new(value.dig("emailAddress")) }
      property :sent_at, from: :sentDateTime, with: ->(sent_date_time) { sent_date_time && Time.parse(sent_date_time) }
      property :payload
      property :recipients
      property :internet_message_id, from: :internetMessageId
      property :web_link, from: :webLink

      def self.build(mail)
        Response.new(mail).tap { |response|
          response.payload = mail

          # For backward compatibility
          response.recipients = response.to_recipients + response.cc_recipients
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

    def fetch(id)
      mail = client.get("messages/#{id}", {})
      Response.build(mail)
    end

    def all(start_time, page_size = 10)
      query_params = params(start_time, page_size)
      response = client.get("messages", query_params)
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

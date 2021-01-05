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
      property :sent_at, from: :sentDateTime, with: ->(sent_date_time) { Time.parse(sent_date_time) }
    end

    attr_reader :client

    def initialize(client:)
      @client = client
    end

    def get(path)
      Response.new(client.get(path, {}))
    end
  end
end

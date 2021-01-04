module MsGraphRest
  class Subscription < Hashie::Trash
    class SignInActivity < Hashie::Trash
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::IgnoreUndeclared

      property :last_sign_in_date_time, from: :lastSignInDateTime
      property :last_sign_in_request_id, from: :lastSignInRequestId
    end

    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::Coercion

    property :display_name, from: :displayName
    property :mail
    property :mail_nickname, from: :mailNickname
    property :other_mails, from: :otherMails
    property :proxy_addresses, from: :proxyAddresses
    property :user_principal_name, from: :userPrincipalName
    property :sign_in_activity, from: :signInActivity

    coerce_key :sign_in_activity, SignInActivity
  end

  class CreateOptions < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess

    property :changeType, from: :change_type
    property :notificationUrl, from: :notification_url
    property :resource
    property :expirationDateTime, from: :expiration_date_time
    property :clientState, from: :client_state
  end

  class CreateResponse < Hashie::Trash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::IgnoreUndeclared

    property :id
    property :resource
    property :application_id, from: :applicationId
    property :change_type, from: :changeType
    property :client_state, from: :clientState
    property :notification_url, from: :notificationUrl
    property :expiration_date_time, from: :expirationDateTime
    property :creator_id, from: :creatorId
    property :odata_context, from: '@odata.context'
  end

  class Subscriptions
    attr_reader :client

    def initialize(client:)
      @client = client
    end

    def create(options)
      options = CreateOptions.new(options.to_hash)
      CreateResponse.new(client.post("subscriptions", options))
    end

    def delete(id)
      client.delete("subscriptions/#{id.to_str}")
      true
    end
  end
end

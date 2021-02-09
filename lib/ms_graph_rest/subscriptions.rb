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

  class Subscriptions
    class SaveOptions < Hashie::Trash
      include Hashie::Extensions::IndifferentAccess

      property :changeType, from: :change_type
      property :notificationUrl, from: :notification_url
      property :resource
      property :expirationDateTime, from: :expiration_date_time
      property :clientState, from: :client_state
    end

    class SaveResponse < Hashie::Trash
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
      property :lifecycle_notification_url, from: :lifecycleNotificationUrl
      property :encryption_certificate, from: :encryptionCertificate
      property :encryption_certificate_id, from: :encryptionCertificateId
      property :include_resource_data, from: :includeResourceData
    end

    attr_reader :client

    def initialize(client:)
      @client = client
    end

    def create(options)
      options = SaveOptions.new(options.to_hash)
      SaveResponse.new(client.post("subscriptions", options))
    end

    def delete(id)
      client.delete("subscriptions/#{id.to_str}")
      true
    end

    def update(id, options)
      options = SaveOptions.new(options.to_hash)
      SaveResponse.new(client.patch("subscriptions/#{id.to_str}", options))
    end

    def get(id)
      response = client.get("subscriptions/#{id.to_str}", {})
      SaveResponse.new(response)
    rescue Faraday::ResourceNotFound
      raise MsGraphRest::ResourceNotFound
    end

    def all
      subscriptions = client.get("subscriptions", {})
      subscriptions.fetch("value", []).map { |subscription| SaveResponse.new(subscription) }
    end
  end
end

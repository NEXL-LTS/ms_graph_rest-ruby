require 'ms_graph_rest/version'
require 'hashie'

module MsGraphRest
  class Error < StandardError; end

  class User < Hashie::Trash
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

  class Users
    class Response
      include Enumerable

      def initialize(data)
        @data = data
      end

      def each
        value.each do |val|
          yield(User.new(val))
        end
      end

      def size
        value.size
      end

      def [](key)
        @data[key]
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

    attr_reader :client
    attr_reader :query

    def initialize(client:, query: {})
      @client = client
      @query = query
    end

    def get
      Response.new(client.get("users", query))
    end

    def filter(val)
      new_with_query(query.merge('$filter' => val))
    end

    def select(val)
      new_with_query(query.merge('$select' => val))
    end

    private

    def new_with_query(query)
      self.class.new(client: client,
                     query: query)
    end
  end

  class Client
    require 'faraday'
    require 'multi_json'
    attr_reader :conn

    def initialize(access_token:)
      @conn = Faraday.new(url: 'https://graph.microsoft.com/v1.0/',
                          headers: { 'Content-Type' => 'application/json' }) do |c|
        c.use Faraday::Response::RaiseError
        c.authorization :Bearer, access_token
        c.adapter Faraday.default_adapter # make requests with Net::HTTP
        c.options.timeout = 25 # open/read timeout in seconds
        c.options.open_timeout = 25 # connection open timeout in seconds
      end
    end

    def get(path, params)
      response = conn.get(path, params.sort)
      MultiJson.load(response.body)
    end

    def users
      Users.new(client: self)
    end
  end

  def self.new_client(access_token:)
    Client.new(access_token: access_token)
  end
end

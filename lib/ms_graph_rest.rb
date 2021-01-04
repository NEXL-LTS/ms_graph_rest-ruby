require 'hashie'
require_relative 'ms_graph_rest/version'
require_relative 'ms_graph_rest/mails'
require_relative 'ms_graph_rest/users'
require_relative 'ms_graph_rest/subscriptions'

module MsGraphRest
  class Error < StandardError; end

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
      response = conn.get(path, params)
      MultiJson.load(response.body)
    end

    def post(path, body)
      response = conn.post(path, body.to_json)
      MultiJson.load(response.body)
    end

    def users
      Users.new(client: self)
    end

    def subscriptions
      Subscriptions.new(client: self)
    end

    def mails
      Mails.new(client: self)
    end
  end

  def self.new_client(access_token:)
    Client.new(access_token: access_token)
  end
end

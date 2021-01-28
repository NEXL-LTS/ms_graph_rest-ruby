require 'hashie'
require_relative 'ms_graph_rest/version'
require_relative 'ms_graph_rest/mails'
require_relative 'ms_graph_rest/error'
require_relative 'ms_graph_rest/users'
require_relative 'ms_graph_rest/subscriptions'
require_relative 'ms_graph_rest/calendar_view'
require_relative 'ms_graph_rest/messages'
require_relative 'ms_graph_rest/photos'

module MsGraphRest
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

    def get_raw(path, params)
      conn.get(path, params)
    rescue Faraday::ResourceNotFound => e
      raise ResourceNotFound.new(e)
    end

    def get(path, params)
      response = get_raw(path, params)
      MultiJson.load(response.body)
    end

    def post(path, body)
      response = conn.post(path, body.to_json)
      MultiJson.load(response.body)
    end

    def patch(path, body)
      response = conn.patch(path, body.to_json)
      MultiJson.load(response.body)
    end

    def delete(path)
      conn.delete(path)
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

    def photos
      Photos.new(client: self)
    end

    def calendar_view(path = '/me/calendar/')
      CalendarView.new(path, client: self)
    end

    def messages(path = 'me')
      Messages.new(path, client: self)
    end
  end

  def self.new_client(access_token:)
    Client.new(access_token: access_token)
  end
end

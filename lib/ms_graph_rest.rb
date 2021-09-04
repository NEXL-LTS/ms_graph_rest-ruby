require 'hashie'
require 'faraday'
require 'multi_json'

require_relative 'ms_graph_rest/version'
require_relative 'ms_graph_rest/mails'
require_relative 'ms_graph_rest/error'
require_relative 'ms_graph_rest/users'
require_relative 'ms_graph_rest/subscriptions'
require_relative 'ms_graph_rest/calendar_view'
require_relative 'ms_graph_rest/messages'
require_relative 'ms_graph_rest/photos'
require_relative 'ms_graph_rest/groups'
require_relative 'ms_graph_rest/planner_tasks'
require_relative 'ms_graph_rest/todo_lists'
require_relative 'ms_graph_rest/todo_list_tasks'

class Faraday::FileReadAdapter < Faraday::Adapter
  def self.folder=(val)
    @folder = val
    FileUtils.mkdir_p(@folder)
  end

  def self.folder
    @folder || default_folder
  end

  def self.reset_folder
    @folder = nil
  end

  def self.default_folder
    "#{Dir.pwd}/tmp/fake_client"
  end

  def call(env)
    super
    method = env.method
    path = env.url.path
    filename = build_filename(env.url.query, env.request_body)
    data = File.read(filename(method, path, filename))
    save_response(env, 200, data)
  rescue Errno::ENOENT => e
    save_response(env, 418, { 'error' => e.message })
  end

  private

  def build_filename(query, request_body)
    if request_body
      payload_hash = MultiJson.load(request_body)
      add = payload_hash.to_a.map { |v| v.join("=") }.join("&").tr(".", "_")
      "#{query}#{add}"
    else
      query
    end
  end

  def filename(method, path, query)
    query = "default" if query.blank?
    "#{self.class.folder}/#{method}#{path.tr("/", "_")}/#{query}.json"
  end
end

module MsGraphRest
  cattr_accessor :use_fake

  def self.fake_folder=(val)
    Faraday::FileReadAdapter.folder = val
  end

  class BaseConnection
    attr_reader :access_token

    def initialize(access_token:)
      @access_token = access_token.to_str.clone.freeze
    end
  end

  class FaradayConnection < BaseConnection
    attr_reader :faraday_adapter

    def initialize(access_token:, faraday_adapter:)
      super(access_token: access_token)
      @faraday_adapter = faraday_adapter
    end

    def conn
      @conn ||= Faraday.new(url: 'https://graph.microsoft.com/v1.0/',
                            headers: { 'Content-Type' => 'application/json' }) do |c|
        c.use Faraday::Response::RaiseError
        c.authorization :Bearer, access_token
        c.adapter faraday_adapter
        c.options.timeout = 60 # open/read timeout in seconds
        c.options.open_timeout = 60 # connection open timeout in seconds
      end
    end

    def get_raw(path, params)
      conn.get(path, params)
    rescue Faraday::Error => e
      raise MsGraphRest.wrap_request_error(e)
    end

    def get(path, params)
      response = get_raw(path, params)
      parse_response(response)
    end

    def post(path, body)
      response = conn.post(path, body.to_json)
      parse_response(response)
    end

    def patch(path, body)
      response = conn.patch(path, body.to_json)
      parse_response(response)
    end

    def delete(path)
      conn.delete(path)
    end

    private

    def parse_response(response)
      MultiJson.load(response.body)
    rescue MultiJson::ParseError => e
      raise MsGraphRest::ParseError.new(e.message, response.body)
    end
  end

  class Client
    attr_reader :connection

    def initialize(access_token:, faraday_adapter: Faraday.default_adapter)
      @connection = FaradayConnection.new(access_token: access_token, faraday_adapter: faraday_adapter)
    end

    def users
      Users.new(client: connection)
    end

    def subscriptions
      Subscriptions.new(client: connection)
    end

    def mails
      Mails.new(client: connection)
    end

    def photos
      Photos.new(client: connection)
    end

    def calendar_view(path = '/me/calendar/')
      CalendarView.new(path, client: connection)
    end

    def messages(path = 'me')
      Messages.new(path, client: connection)
    end

    def groups
      Groups.new(client: connection)
    end

    def planner_tasks(path = 'me/planner/tasks')
      PlannerTasks.new(path, client: connection)
    end

    def todo_lists
      TodoLists.new(client: connection)
    end

    def todo_list_tasks(todo_list_id)
      TodoListTasks.new(todo_list_id, client: connection)
    end
  end

  def self.new_client(access_token:)
    faraday_adapter = use_fake ? Faraday::FileReadAdapter : Faraday.default_adapter
    Client.new(access_token: access_token, faraday_adapter: faraday_adapter)
  end
end

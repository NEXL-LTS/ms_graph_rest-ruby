require 'hashie'
require 'faraday'
require 'multi_json'

require_relative 'ms_graph_rest/version'
require_relative 'ms_graph_rest/calendar_create_event'
require_relative 'ms_graph_rest/calendar_update_event'
require_relative 'ms_graph_rest/calendar_cancel_event'
require_relative 'ms_graph_rest/calendar_get_schedule'
require_relative 'ms_graph_rest/calendar_groups'
require_relative 'ms_graph_rest/calendar_view'
require_relative 'ms_graph_rest/calendars'
require_relative 'ms_graph_rest/online_meetings'

require_relative 'ms_graph_rest/error'
require_relative 'ms_graph_rest/find_rooms'
require_relative 'ms_graph_rest/groups'
require_relative 'ms_graph_rest/mails'
require_relative 'ms_graph_rest/messages'
require_relative 'ms_graph_rest/message'
require_relative 'ms_graph_rest/messages_delta'
require_relative 'ms_graph_rest/photos'
require_relative 'ms_graph_rest/places'
require_relative 'ms_graph_rest/planner_tasks'
require_relative 'ms_graph_rest/subscriptions'
require_relative 'ms_graph_rest/todo_list_tasks'
require_relative 'ms_graph_rest/todo_lists'
require_relative 'ms_graph_rest/users'

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
    attr_reader :access_token, :version

    def initialize(access_token:, version: 'v1.0')
      @access_token = access_token.to_str.clone.freeze
      @version = version
    end
  end

  class FaradayConnection < BaseConnection
    attr_reader :faraday_adapter

    def initialize(access_token:, faraday_adapter:, version: 'v1.0')
      super(access_token: access_token, version: version)
      @faraday_adapter = faraday_adapter
    end

    def conn
      @conn ||= Faraday.new(url: "https://graph.microsoft.com/#{@version}/",
                            headers: { 'Content-Type' => 'application/json' }) do |c|
        c.use Faraday::Response::RaiseError
        c.request :authorization, 'Bearer', access_token
        c.adapter faraday_adapter
        c.options.timeout = 120 # open/read timeout in seconds
        c.options.open_timeout = 120 # connection open timeout in seconds
      end
    end

    def get_raw(path, params, headers = {})
      conn.get(path, params, headers)
    rescue Faraday::Error => e
      raise MsGraphRest.wrap_request_error(e)
    end

    # @param consistencylevel [String] "eventual"
    def get(path, params, consistencylevel: nil, headers: {})
      if consistencylevel
        headers["consistencylevel"] = consistencylevel
      end
      response = get_raw(path, params, headers)
      parse_response(response)
    end

    def post(path, body, headers: {})
      response = conn.post(path, body.to_json, headers)
      parse_response(response)
    end

    def patch(path, body, headers: {})
      response = conn.patch(path, body.to_json, headers)
      parse_response(response)
    end

    def delete(path)
      conn.delete(path)
    end

    private

    def parse_response(response)
      body = response.body
      if body.empty?
        true
      else
        MultiJson.load(response.body)
      end
    rescue MultiJson::ParseError => e
      raise MsGraphRest::ParseError.new(e.message, response.body)
    end
  end

  class Client
    attr_reader :connection

    def initialize(access_token:, faraday_adapter: Faraday.default_adapter, version: 'v1.0')
      @connection = FaradayConnection.new(access_token: access_token, faraday_adapter: faraday_adapter,
                                          version: version)
    end

    # @return Users
    def users
      Users.new(client: connection)
    end

    def subscriptions
      Subscriptions.new(client: connection)
    end

    # @return MsGraphRest::Mails
    def mails
      Mails.new(client: connection)
    end

    # @return MsGraphRest::Photos
    def photos
      Photos.new(client: connection)
    end

    # @return MsGraphRest::CalendarView
    def calendar_view
      CalendarView.new(client: connection)
    end

    # @return MsGraphRest::CalendarGetSchedule
    def calendar_get_schedule
      CalendarGetSchedule.new(client: connection)
    end

    # @return MsGraphRest::OnlineMeetings
    def online_meetings
      OnlineMeetings.new(client: connection)
    end

    # @return MsGraphRest::CalendarCreateEvent
    def calendar_create_event
      CalendarCreateEvent.new(client: connection)
    end

    # @return MsGraphRest::CalendarUpdateEvent
    def calendar_update_event
      CalendarUpdateEvent.new(client: connection)
    end

    # @return MsGraphRest::CalendarCancelEvent
    def calendar_cancel_event
      CalendarCancelEvent.new(client: connection)
    end

    # @return MsGraphRest::CalendarCreateEvent
    def calendar_groups
      CalendarGroups.new(client: connection)
    end

    # @return MsGraphRest::CalendarCreateEvent
    def calendars
      Calendars.new(client: connection)
    end

    # @return MsGraphRest::Places
    def places
      Places.new(client: connection)
    end

    def messages(path = 'me')
      Messages.new(path, client: connection)
    end

    def message(path = 'me')
      Message.new(path, client: connection)
    end

    def messages_delta(path = 'me', folder = 'inbox')
      MessagesDelta.new(path, folder, client: connection)
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

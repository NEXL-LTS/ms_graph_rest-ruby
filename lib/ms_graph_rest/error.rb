module MsGraphRest
  def self.wrap_request_error(faraday_error)
    case faraday_error
    when Faraday::ResourceNotFound
      NotFoundErrorCreator.error(faraday_error)
    when Faraday::BadRequestError
      BadRequestErrorCreator.error(faraday_error)
    when Faraday::ClientError
      ClientErrorCreator.error(faraday_error)
    when Faraday::ServerError
      ServerErrorCreator.error(faraday_error)
    else
      faraday_error
    end
  end

  Error = Class.new(StandardError)

  class ParseError < Error
    attr_reader :response

    def initialize(input, response = nil)
      @response = response
      super(input)
    end
  end

  class HttpError < StandardError
    attr_reader :response

    def initialize(input)
      @response = input.response if input.respond_to?(:response)
      super(input)
    end
  end

  ResourceNotFound = Class.new(HttpError)
  UserNotFound = Class.new(ResourceNotFound)
  MailboxNotEnabledError = Class.new(ResourceNotFound)
  ItemNotFoundError = Class.new(ResourceNotFound)

  class NotFoundErrorCreator
    def self.error(faraday_error)
      if faraday_error.response
        parsed_error = MultiJson.load(faraday_error.response[:body] || '{}')
        message = parsed_error.dig("error", "message")
        code = parsed_error.dig("error", "code")

        return UserNotFound.new(faraday_error) if message == 'User not found'
        return MailboxNotEnabledError.new(faraday_error) if code == 'MailboxNotEnabledForRESTAPI'
        return ItemNotFoundError.new(faraday_error) if code == 'ErrorItemNotFound'
      end

      ResourceNotFound.new(faraday_error)
    rescue TypeError, MultiJson::ParseError
      ResourceNotFound.new(faraday_error)
    end
  end

  AuthenticationError = Class.new(HttpError)

  class BadRequestErrorCreator
    def self.error(ms_error)
      ms_error_code = JSON.parse(ms_error.response[:body] || '{}').dig("error", "code")

      return AuthenticationError.new(ms_error) if ms_error_code == 'AuthenticationError'

      return ms_error
    end
  end

  MailboxConcurrencyLimitError = Class.new(HttpError)
  InvalidAuthenticationTokenError = Class.new(HttpError)

  class ClientErrorCreator
    def self.error(faraday_error)
      return faraday_error if faraday_error.response.nil?

      parsed_error = MultiJson.load(faraday_error.response[:body] || '{}')
      message = parsed_error.dig("error", "message")
      code = parsed_error.dig("error", "code")

      if message == 'Application is over its MailboxConcurrency limit.'
        return MailboxConcurrencyLimitError.new(faraday_error)
      end
      return InvalidAuthenticationTokenError.new(faraday_error) if code == 'InvalidAuthenticationToken'

      faraday_error
    rescue TypeError, MultiJson::ParseError
      faraday_error
    end
  end

  HttpServerError = Class.new(HttpError)
  UnableToResolveUserId = Class.new(HttpServerError)
  ResourceUnhealthyError = Class.new(HttpServerError)
  MailboxStoreUnavailableError = Class.new(HttpServerError)
  ServiceUnavailableError = Class.new(HttpServerError)

  class ServerErrorCreator
    def self.error(faraday_error)
      return faraday_error if faraday_error.response.nil?

      raw_body = faraday_error.response[:body]
      return ServiceUnavailableError.new(faraday_error) if raw_body.to_s.include?('503 Service Unavailable')
      return ServiceUnavailableError.new(faraday_error) if raw_body.to_s.include?('The service is unavailable')

      parsed_error = MultiJson.load(raw_body || '{}')
      message = parsed_error.dig("error", "message")
      error_code = parsed_error.dig("error", "code")

      return UnableToResolveUserId.new(faraday_error) if message == 'Unable to resolve User Id'
      return ResourceUnhealthyError.new(faraday_error) if error_code == 'ResourceUnhealthy'
      return MailboxStoreUnavailableError.new(faraday_error) if error_code == 'ErrorMailboxStoreUnavailable'

      faraday_error
    rescue TypeError, MultiJson::ParseError
      faraday_error
    end
  end
end

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

  class HttpError < Error
    attr_reader :response

    def initialize(input)
      @response = input.response if input.respond_to?(:response)
      super(input)
    end
  end

  ClientError = Class.new(HttpError)
  ResourceNotFound = Class.new(ClientError)
  UserNotFound = Class.new(ResourceNotFound)
  MailboxNotEnabledError = Class.new(ResourceNotFound)
  ItemNotFoundError = Class.new(ResourceNotFound)
  ResourceNotDiscovered = Class.new(ResourceNotFound)

  class NotFoundErrorCreator
    def self.error(faraday_error)
      if faraday_error.response
        parsed_error = MultiJson.load(faraday_error.response[:body] || '{}')
        message = parsed_error.dig("error", "message")
        code = parsed_error.dig("error", "code")

        return UserNotFound.new(faraday_error) if message == 'User not found'
        return ResourceNotDiscovered.new(faraday_error) if message == 'Resource could not be discovered.'
        return MailboxNotEnabledError.new(faraday_error) if code == 'MailboxNotEnabledForRESTAPI'
        return ItemNotFoundError.new(faraday_error) if code == 'ErrorItemNotFound'
      end

      ResourceNotFound.new(faraday_error)
    rescue TypeError, MultiJson::ParseError
      ResourceNotFound.new(faraday_error)
    end
  end

  BadRequestError = Class.new(ClientError)
  AuthenticationError = Class.new(BadRequestError)
  InvalidGrantError = Class.new(BadRequestError)
  NamedPropertyNotFoundError = Class.new(BadRequestError)

  class BadRequestErrorCreator
    def self.error(ms_error)
      ms_error_code = JSON.parse(ms_error.response[:body] || '{}').dig("error")
      ms_error_msg = nil
      if ms_error_code.is_a?(Hash)
        ms_error_msg = ms_error_code["message"]
        ms_error_code = ms_error_code["code"]
      end

      return AuthenticationError.new(ms_error) if ms_error_code == 'AuthenticationError'
      return InvalidGrantError.new(ms_error) if ms_error_code == 'invalid_grant'
      if ms_error_code == "RequestBroker-ParseUri" && ms_error_msg&.include?("not find a property")
        return NamedPropertyNotFoundError.new(ms_error)
      end

      return ms_error
    end
  end

  MailboxConcurrencyLimitError = Class.new(ClientError)
  InvalidAuthenticationTokenError = Class.new(ClientError)
  ForbiddenError = Class.new(ClientError)
  RequestTimeoutError = Class.new(ClientError)

  class ClientErrorCreator
    def self.error(faraday_error)
      return ForbiddenError.new(faraday_error) if faraday_error.is_a?(Faraday::ForbiddenError)
      return RequestTimeoutError.new(faraday_error) if faraday_error.response[:status].to_s == '408'
      return faraday_error if faraday_error.response.nil?

      error_from_body(faraday_error) || faraday_error
    rescue TypeError, MultiJson::ParseError
      faraday_error
    end

    def self.error_from_body(faraday_error)
      parsed_error = MultiJson.load(faraday_error.response[:body] || '{}')
      message = parsed_error.dig("error", "message")
      code = parsed_error.dig("error", "code")

      if message == 'Application is over its MailboxConcurrency limit.'
        return MailboxConcurrencyLimitError.new(faraday_error)
      end

      InvalidAuthenticationTokenError.new(faraday_error) if code == 'InvalidAuthenticationToken'
    end
  end

  HttpServerError = Class.new(HttpError)
  UnableToResolveUserId = Class.new(HttpServerError)
  ResourceUnhealthyError = Class.new(HttpServerError)
  UnavailableError = Class.new(HttpServerError)
  MailboxStoreUnavailableError = Class.new(UnavailableError)
  ServiceUnavailableError = Class.new(UnavailableError)
  BadGatewayError = Class.new(HttpServerError)
  UnknownServerError = Class.new(HttpServerError)
  ErrorContentConversionFailed = Class.new(HttpServerError)

  class ServerErrorCreator
    def self.error(faraday_error)
      return faraday_error if faraday_error.response.nil?

      message, error_code, status = message_and_code(faraday_error.response)

      return UnableToResolveUserId.new(faraday_error) if message == 'Unable to resolve User Id'
      return ResourceUnhealthyError.new(faraday_error) if error_code == 'ResourceUnhealthy'
      return MailboxStoreUnavailableError.new(faraday_error) if error_code == 'ErrorMailboxStoreUnavailable'
      return ServiceUnavailableError.new(faraday_error) if status.to_s == '503'
      return BadGatewayError.new(faraday_error) if status.to_s == '504'
      return UnknownServerError.new(faraday_error) if error_code == 'UnknownError'
      return ErrorContentConversionFailed.new(faraday_error) if error_code == 'ErrorContentConversionFailed'

      faraday_error
    end

    def self.message_and_code(response)
      message = nil
      error_code = nil
      status = nil
      begin
        status = response[:status]
        message = response[:body]
        parsed_error = MultiJson.load(response[:body] || '{}')
        message = parsed_error.dig("error", "message")
        error_code = parsed_error.dig("error", "code")
      rescue TypeError, MultiJson::ParseError
        # nop
      end
      [message, error_code, status]
    end
  end
end

module MsGraphRest
  class Error < StandardError
  end

  class ResourceNotFound < Error
  end

  class AuthenticationError < Error
  end

  class BadRequestErrorCreator
    def self.error(ms_error)
      ms_error_code = JSON.parse(ms_error.response[:body] || '{}').dig("error", "code")

      return AuthenticationError.new(ms_error) if ms_error_code == 'AuthenticationError'

      Error.new(ms_error)
    end
  end
end

module Riff
  module Exceptions
    class RiffError < StandardError
      JSON = false
    end

    class Error422 < RiffError
      WEB_STATUS = 422
    end

    class Error404 < RiffError
      WEB_STATUS = 404
    end

    class Error500 < RiffError
      WEB_STATUS = 500
    end

    # 400
    class AuthenticationFailure < RiffError
      ERR_MSG = 'Authentication failure'
      WEB_STATUS = 401
    end

    class InvalidEmailOrPassword < RiffError
      ERR_MSG = 'Invalid email or password'
      WEB_STATUS = 401
    end

    class AuthorizationFailure < RiffError
      ERR_MSG = 'Authorization failure'
      WEB_STATUS = 403
    end

    # 422
    class InvalidPathNodes < Error422
      ERR_MSG = 'Invalid path nodes'
    end

    class InvalidRequestPath < Error422
      ERR_MSG = 'Invalid request path'
    end

    class OutOfBoundsPathNodes < Error422
      ERR_MSG = 'Out of bounds path nodes'
    end

    class InvalidParams < Error422
      ERR_MSG = 'Invalid parameters'
      JSON = true
    end

    class SequelInvalidParams < Error422
      ERR_MSG = 'Invalid parameters'
      JSON = true
    end

    # 404
    class ResourceNotFound < Error404
      ERR_MSG = 'Resource not found'
    end

    class ActionNotFound < Error404
      ERR_MSG = 'Action not found'

      def self.create(path, request_method)
        new("path='#{path}' verb='#{request_method}'")
      end
    end

    # 500
    class InvalidResponseBody < Error500
      ERR_MSG = 'Invalid response body'
    end
  end
end

# frozen_string_literal: true

module Riff
  module Exceptions
    class RiffError < StandardError
      JSON = false

      def default_err_msg
        self.class.name.split("::").last.gsub(/([A-Z])/, ' \1').strip.downcase.capitalize
      end
    end

    class Error401 < RiffError
      WEB_STATUS = 401
    end

    class Error403 < RiffError
      WEB_STATUS = 403
    end

    class Error422 < RiffError
      WEB_STATUS = 422
    end

    class Error428 < RiffError
      WEB_STATUS = 428
    end

    class Error404 < RiffError
      WEB_STATUS = 404
    end

    class Error500 < RiffError
      WEB_STATUS = 500
    end

    # 40*
    class AuthFailure < Error401
    end

    class InvalidEmailOrPassword < Error401
    end

    class AuthorizationFailure < Error403
    end

    class InvalidPathNodes < Error422
    end

    class InvalidRequestPath < Error422
    end

    class OutOfBoundsPathNodes < Error422
    end

    class InvalidParameters < Error422
      JSON = true
    end

    class DbValidationError < Error422
      JSON = true
    end

    class PreconditionFailed < Error428
    end

    class ResourceNotFound < Error404
      def self.create(resource, id)
        new("unable to find #{resource.to_s.singularize} with id '#{id}'")
      end
    end

    class ActionNotFound < Error404
      def self.create(path, request_method, details: nil)
        msg = "path=#{path} verb=#{request_method}"
        msg += ", #{details}" if details
        new(msg)
      end
    end

    # 50*
    class InvalidResponseBody < Error500
    end

    class NotImplemented < Error500
    end

    class InvalidAuthorizationResult < Error500
    end

    class InternalServerError < Error500
    end
  end
end

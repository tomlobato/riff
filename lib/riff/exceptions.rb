# frozen_string_literal: true

module Riff
  module Exceptions
    class RiffError < StandardError
      JSON = false

      attr_accessor :display_msg, :field_errors, :raw_msg

      # Creates a RiffError instance.

      # message: string, low level error message, never shown to user (hidden in production).
      # display_msg: string, high level error message, shown to user.
      #   Defaults to #message_from_class_name if WEB_STATUS is 4*, and Conf.default_display_error_msg otherwise.
      # field_errors: hash, errors by field, shown to user on invalid form submits.
      # raw_msg: hash, raw error message sent to frontend. If set, no other parameters are used.

      def self.create(message = nil, display_msg: nil, field_errors: nil, raw_msg: nil)
        new(message).tap do |e|
          e.display_msg = display_msg
          e.field_errors = field_errors
          e.raw_msg = raw_msg
        end
      end

      def self.raise!(message = nil, display_msg: nil, field_errors: nil, raw_msg: nil)
        raise(create(message, display_msg: display_msg, field_errors: field_errors, raw_msg: raw_msg))
      end

      def message_from_class_name
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

    class InvalidCredentials < Error401
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

    class ContentTypeAlreadySet < Error500
    end

    class InvalidContentType < Error500
    end

    class ActionExecutionError < Error500
    end
  end
end

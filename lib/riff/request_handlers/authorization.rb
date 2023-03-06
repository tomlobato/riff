# frozen_string_literal: true

module Riff
  module RequestHandlers
    class Authorization < Base
      private

      def setup
        @authorizer_class = authorizer_class
      end

      def authorizer_class
        Util.const_get([:Actions, model_name, :Authorizer], anchor: true)
      end

      def run
        raise_authorization_error! unless @authorizer_class

        handle_result(check_permission)
      end

      def check_permission
        @authorizer_class.new(@context, user).__send__("#{@context.action}?")
      rescue StandardError
        raise_authorization_error!
      end

      def handle_result(result)
        case result
        when true
          # allow
        when false, nil
          raise_authorization_error!
        when Hash
          @context.set(:scope, result.symbolize_keys)
          nil
        else
          raise(invalid_authorization_result(result))
        end
      end

      def raise_authorization_error!
        raise(Exceptions::AuthorizationFailure)
      end

      def user
        @context.get(:user)
      end

      def invalid_authorization_result(result)
        msg = "Authorization result must be one of true, false, nil or a hash. We got a '#{result.class}'."
        Exceptions::InvalidAuthorizationResult.new(msg)
      end
    end
  end
end

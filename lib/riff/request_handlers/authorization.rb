# frozen_string_literal: true

module Riff
  module RequestHandlers
    class Authorization < Base
      private

      def setup
        @authorizer_class = authorize_class
      end

      def authorize_class
        Util.const_get(class_nodes, anchor: true)
      end

      def class_nodes
        [Conf.resources_base_module, module_name, :Authorize]
      end

      def run
        raise_authorization_error!("Class #{class_nodes.join("::")} must be implemented") unless @authorizer_class

        handle_result(check_permission)
      end

      def check_permission
        instance = @authorizer_class.new(@context, user)
        method = "#{@context.action}?".to_sym
        unless instance.respond_to?(method)
          raise_authorization_error!("Method #{method} must be implemented in #{@authorizer_class}")
        end

        instance.__send__(method)
      end

      def handle_result(result)
        case result
        when true
          # allow
        when false, nil
          raise_authorization_error!
        when Hash
          @context.scope = result.symbolize_keys
          nil
        else
          raise(invalid_authorization_result(result))
        end
      end

      def raise_authorization_error!(msg = nil)
        raise(Exceptions::AuthorizationFailure, msg)
      end

      def user
        @context.user
      end

      def invalid_authorization_result(result)
        msg = "Authorization result must be one of true, false, nil or a hash. We`ve got a '#{result.class}'."
        Exceptions::InvalidAuthorizationResult.new(msg)
      end
    end
  end
end

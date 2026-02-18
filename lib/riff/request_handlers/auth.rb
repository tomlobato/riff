# frozen_string_literal: true

module Riff
  module RequestHandlers
    class Auth < Base
      private

      def run
        return unless auth_enabled?

        user = authenticate
        if user
          @context.user = user 
          Conf.on_user&.new(user, :request, @context)&.call
        end
        nil
      end

      def auth_enabled?
        Conf.default_auth_user_class
      end

      def authenticate
        auth_methods.each do |method|
          instance = method.new(@context)
          next info_log("Request is not authenticable with method #{method}") unless instance.request_is_authenticable?

          user = instance.authenticate
          raise(Exceptions::AuthFailure) unless user

          return user
        end
        raise(Exceptions::AuthFailure)
      end

      def info_log(msg)
        Conf.logger.info(msg)
      end

      def auth_methods
        action_custom_auth_methods ||
          resource_custom_auth_methods ||
          Conf.custom_auth_method ||
          [Riff::Auth::DefaultMethod::RequestAuth]
      end

      def resource_custom_auth_methods
        settings = @context.settings
        return unless settings && settings.class.respond_to?(:auth_method)

        methods = [settings.class.auth_method].flatten.compact
        methods.presence
      end

      def action_custom_auth_methods
        action_class = @context.action_class
        return unless action_class.respond_to?(:auth_method)

        methods = [action_class.auth_method].flatten.compact
        methods.presence
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module RequestHandlers
    class Auth < Base
      private

      def run
        return unless auth_enabled?

        user = authenticate
        @context.set(:user, user) if user
        on_auth(user)
        nil
      end

      def auth_enabled?
        Conf.get(:default_auth_user_class)
      end

      def authenticate
        methods.each do |method|
          instance = method.new(@context)
          next info_log("Request is not authenticable with method #{method}") unless instance.request_is_authenticable?

          user = instance.authenticate
          raise(Exceptions::AuthFailure) unless user

          return user
        end
        raise(Exceptions::AuthFailure)
      end

      def info_log(msg)
        Application['logger'].info(msg)
      end

      def methods
        action_custom_auth_methods || 
          resource_custom_auth_methods || 
          Conf.get(:custom_auth_method) || 
          [Riff::Auth::DefaultMethod::RequestAuth]
      end

      def resource_custom_auth_methods
        settings = @context.get(:settings)
        [settings.class.auth_method].flatten if settings && settings.class.respond_to?(:auth_method)
      end
      
      def action_custom_auth_methods
        action_class = @context.get(:action_class)
        [action_class.auth_method].flatten if action_class.respond_to?(:auth_method)
      end

      def on_auth(user)
        on_auth_handlers.each do |handler|
          handler.new(user).call
        end
      end

      def on_auth_handlers
        [Conf.get(:on_auth)].flatten.compact
      end
    end
  end
end

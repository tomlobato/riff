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
        custom_resource_methods || 
          Conf.get(:custom_auth_method) || 
          [Riff::Auth::DefaultMethod::RequestAuth]
      end

      def custom_resource_methods
        settings = @context.get(:settings)
        [settings.auth_method].flatten if settings && settings.respond_to?(:auth_method)
      end

      def on_auth(user)
        Object.const_get('OnRiffAuth').new(user).call
      rescue NameError
      end
    end
  end
end

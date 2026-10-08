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
          if (on_user = Conf.on_user)
            on_user.new(user, :request, @context).call
          end
        end
        nil
      end

      def auth_enabled?
        a = @context.action_class
        s = @context.settings
        return false if a.respond_to?(:auth_enabled?) && !s.auth_enabled? ||
                        s.respond_to?(:auth_enabled?) && !s.auth_enabled?

        true
      end

      def authenticate
        [methods].flatten.each do |method|
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

      def methods
        action_custom_auth_methods ||
          resource_custom_auth_methods ||
          Conf.custom_auth_method ||
          Riff::Auth::DefaultMethod::RequestAuth
      end

      def resource_custom_auth_methods
        settings = @context.settings
        settings.class.auth_method if settings && settings.class.respond_to?(:auth_method)
      end

      def action_custom_auth_methods
        action_class = @context.action_class
        action_class.auth_method if action_class.respond_to?(:auth_method)
      end
    end
  end
end

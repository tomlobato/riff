# frozen_string_literal: true

module Riff
  module RequestHandlers
    class Authentication < Base
      private

      def run
        return unless authentication_enabled?

        user = authenticate
        @context.set(:user, user) if user
        nil
      end

      def authentication_enabled?
        Conf.get(:default_user_class)
      end

      def authenticate
        method.new(@context).authenticate
      end

      def method
        custom_resource_method || 
          Conf.get(:custom_authentication_method) || 
          Riff::Authentication::DefaultMethod
      end

      def custom_resource_method
        settings = @context.get(:settings)
        settings.authentication_method if settings && settings.respond_to?(:authentication_method)
      end
    end
  end
end

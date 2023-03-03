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
        Conf.get(:user_class)
      end

      def authenticate
        ::Riff::Authentication::TokenValidator.new(authorization_token, purpose).call
      end

      def purpose
        @context.url.include?("refresh_token") ? :refresh_token : :access_token
      end

      def authorization_token
        @context.headers["Authorization"]
      end
    end
  end
end

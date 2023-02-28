module Riff
  module RequestHandlers
    class Authentication < Base
      private

      def run
        user = authenticate
        @context.set(:user, user) if user
        nil
      end

      def authenticate
        ::Riff::Authentication::TokenValidator.new(authorization_token, purpose).call
      end

      def purpose
        @context.url.include?('refresh_token') ? :refresh_token : :access_token
      end

      def authorization_token
        @context.headers['Authorization']
      end
    end
  end
end

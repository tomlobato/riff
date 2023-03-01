module Riff
  module Session
    class Refresh
      def initialize(headers)
        @headers = headers
      end

      def call
        Authentication::UpdateAuthenticationToken.new(user).call
        tokens = Authentication::CreateTokens.new(user).call
        Request::Result.new(body(user))
      end

      private

      def user
        @user ||= ::Riff::Authentication::TokenValidator.new(@headers['Authorization'], :refresh_token).call
      end

      def body(user)
        {
          tokens: Authentication::CreateTokens.new(user).call
        }
      end
    end
  end
end

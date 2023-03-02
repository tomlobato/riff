# frozen_string_literal: true

module Riff
  module Session
    class Refresh
      def initialize(headers)
        @headers = headers
      end

      def call
        raise(Exceptions::AuthenticationFailure) unless user

        Authentication::UpdateAuthenticationToken.new(user).call
        Request::Result.new(body)
      end

      private

      def user
        @user ||= ::Riff::Authentication::TokenValidator.new(@headers["Authorization"], :refresh_token).call
      end

      def body
        {
          tokens: Authentication::CreateTokens.new(user).call
        }
      end
    end
  end
end

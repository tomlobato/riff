# frozen_string_literal: true

module Riff
  module Session
    class Refresh
      def initialize(headers)
        @headers = headers
      end

      def call
        raise(Exceptions::AuthFailure) unless user

        Auth::DefaultMethod::Token::UpdateAuthToken.new(user).call
        Request::Result.new({data: body})
      end

      private

      def user
        @user ||= ::Riff::Auth::DefaultMethod::Token::TokenValidator.new(@headers["Authorization"], :refresh_token).call
      end

      def body
        {
          tokens: ::Riff::Auth::DefaultMethod::Token::CreateTokens.new(user).call
        }
      end
    end
  end
end

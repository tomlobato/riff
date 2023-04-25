# frozen_string_literal: true

module Riff
  module Session
    class Close
      def initialize(headers)
        @headers = headers
      end

      def call
        raise(Exceptions::AuthFailure) unless user

        Riff::Auth::DefaultMethod::Token::InvalidateAuthToken.new(user).call
        Request::Result.new
      end

      private

      def user
        @user ||= Riff::Auth::DefaultMethod::Token::TokenValidator.new(@headers["Authorization"], :access_token).call
      end
    end
  end
end

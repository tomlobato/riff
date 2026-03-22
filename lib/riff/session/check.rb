# frozen_string_literal: true

module Riff
  module Session
    class Check
      def initialize(headers)
        @headers = headers
      end

      def call
        raise(Exceptions::AuthFailure) unless user

        Request::Result.new({ data: { user: user_payload } })
      end

      private

      def user
        @user ||= ::Riff::Auth::DefaultMethod::Token::TokenValidator.new(
          @headers["Authorization"]&.sub(/\ABearer /i, ""), :access_token
        ).call
      end

      def user_payload
        custom_payload_class = Conf.user_login_payload_class
        if custom_payload_class
          custom_payload_class.new(user).call
        else
          user.values.slice(*Open::DEFAULT_USER_PAYLOAD_FIELDS)
        end
      end
    end
  end
end

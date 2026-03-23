# frozen_string_literal: true

module Riff
  module Session
    class Check
      def initialize(headers)
        @headers = headers
      end

      def call
        raise(Exceptions::AuthFailure) unless user

        Request::Result.new({ data: build_data })
      end

      private

      def user
        @user ||= ::Riff::Auth::DefaultMethod::Token::TokenValidator.new(
          @headers["Authorization"]&.sub(/\ABearer /i, ""), :access_token
        ).call
      end

      def build_data
        custom_payload_class = Conf.user_login_payload_class
        if custom_payload_class
          instance = custom_payload_class.new(user)
          data = { user: instance.call }
          data.merge!(instance.session_check_data(@headers)) if instance.respond_to?(:session_check_data)
          data
        else
          { user: user.values.slice(*Open::DEFAULT_USER_PAYLOAD_FIELDS) }
        end
      end
    end
  end
end

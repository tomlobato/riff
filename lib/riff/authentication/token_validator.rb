# frozen_string_literal: true

module Riff
  module Authentication
    class TokenValidator
      def initialize(authorization_token, purpose)
        @message = decode(authorization_token, purpose)
      end

      def call
        raise(Exceptions::AuthenticationFailure) unless valid?

        user
      end

      private

      def decode(authorization_token, purpose)
        MessageSigner.decode(message: authorization_token, purpose: purpose)
      end

      def valid?
        @message && user && user.authentication_token == @message[:authentication_token]
      end

      def user
        @user ||= user_class.find(id: @message[:user_id])
      end

      def user_class
        Conf.get(:default_user_class)
      end
    end
  end
end

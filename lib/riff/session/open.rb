# frozen_string_literal: true

module Riff
  module Session
    class Open
      def initialize(roda_request)
        @roda_request = roda_request
        @params = roda_request.params
      end

      def call
        user = validate_credentials

        Request::Result.new(body(user))
      end

      private

      def body(user)
        {
          user: user.values.slice(:id, :name, :email),
          tokens: Riff::Auth::DefaultMethod::Token::CreateTokens.new(user).call
        }
      end

      def validate_credentials
        [validate_credentials_methods].flatten.each do |method|
          instance = method.new(@roda_request)
          next info_log("Request is not authenticable with method #{method}") unless instance.request_is_authenticable?

          user = instance.authenticate
          return user if user
        end
        raise(Exceptions::AuthFailure)
      end

      def info_log(msg)
        Application['logger'].info(msg)
      end

      def validate_credentials_methods
        Conf.get(:validate_credentials_methods) || default_validate_credentials_methods
      end

      def default_validate_credentials_methods
        Riff::Auth::DefaultMethod::Token::ValidateCredentials
      end
    end
  end
end

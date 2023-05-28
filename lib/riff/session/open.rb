# frozen_string_literal: true

module Riff
  module Session
    class Open
      DEFAULT_USER_PAYLOAD_FIELDS = %i[
        id
        name
        nome
        email
        mail
        e_email
        username
        user_name
        login
        role
        role_id
        company_id
        group_id
        group
        fullname
        full_name
        firstname
        first_name
        lastname
        last_name
        is_admin
        is_administrator
        is_administrador
      ].freeze

      def initialize(roda_request)
        @roda_request = roda_request
        @params = roda_request.params
      end

      def call
        user = validate_credentials

        Request::Result.new({ data: body(user) })
      end

      private

      def body(user)
        {
          user: user_payload(user),
          tokens: Riff::Auth::DefaultMethod::Token::CreateTokens.new(user).call
        }
      end

      def user_payload(user)
        custom_payload_class = Conf.user_login_payload_class
        if custom_payload_class
          custom_payload_class.new(user).call
        else
          user.values.slice(*DEFAULT_USER_PAYLOAD_FIELDS)
        end
      end

      def validate_credentials
        [Conf.validate_credentials_methods].flatten.each do |method|
          instance = method.new(@roda_request)
          next info_log("Request is not authenticable with method #{method}") unless instance.request_is_authenticable?

          user = instance.authenticate
          return user if user
        end
        raise(Exceptions::AuthFailure)
      end

      def info_log(msg)
        Conf.logger.info(msg)
      end
    end
  end
end

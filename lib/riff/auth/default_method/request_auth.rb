# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      class RequestAuth < RequestAuthMethod
        def request_is_authenticable?
          authorization_token.present?
        end

        def authenticate
          Token::TokenValidator.new(authorization_token, purpose).call
        end

        private

        def purpose
          :access_token
        end

        def authorization_token
          @headers["Authorization"]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Auth
    class SigninAuthMethod
      def initialize(roda_request)
        @roda_request = roda_request
        @params = roda_request.params
      end

      def request_is_authenticable?
        raise(NotImplementedError, "#{self.class}#request_is_authenticable? must be implemented")
      end

      def authenticate
        raise(NotImplementedError, "#{self.class}#authenticate must be implemented")
      end

      private

      attr_reader :params

      def raise_auth_error!
        raise(Riff::Exceptions::AuthFailure)
      end
    end
  end
end

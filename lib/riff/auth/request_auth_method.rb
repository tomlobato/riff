# frozen_string_literal: true

module Riff
  module Auth
    class RequestAuthMethod
      def initialize(context)
        @context = context
        @headers = context.headers
      end

      def request_is_authenticable?
        raise("must implement!")
      end

      def authenticate
        raise("must implement!")
      end

      private

      def raise_auth_error!
        raise(Riff::Exceptions::AuthFailure)
      end
    end
  end
end

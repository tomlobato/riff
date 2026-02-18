# frozen_string_literal: true

module Riff
  module Auth
    class RequestAuthMethod
      def initialize(context)
        @context = context
        @headers = context.headers
      end

      def request_is_authenticable?
        raise(NotImplementedError, "#{self.class}#request_is_authenticable? must be implemented")
      end

      def authenticate
        raise(NotImplementedError, "#{self.class}#authenticate must be implemented")
      end

      private

      def raise_auth_error!
        raise(Riff::Exceptions::AuthFailure)
      end
    end
  end
end

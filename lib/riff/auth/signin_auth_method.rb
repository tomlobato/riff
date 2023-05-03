module Riff
  module Auth
    class SigninAuthMethod
      def initialize(roda_request)
        @roda_request = roda_request
        @params = roda_request.params
      end

      def request_is_authenticable?
        raise('must implement!')
      end

      def authenticate
        raise('must implement!')
      end

      private

      attr_reader :params

      def raise_auth_error!
        raise(Riff::Exceptions::AuthFailure)
      end
    end
  end
end

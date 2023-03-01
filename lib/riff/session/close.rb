module Riff
  module Session
    class Close
      def initialize(headers)
        @headers = headers
      end

      def call
        raise(Exceptions::AuthenticationFailure) unless user

        ::Riff::Authentication::UpdateAuthenticationToken.new(user).call
        Result.new
      end

      private

      def user
        @user ||= ::Riff::Authentication::TokenValidator.new(@headers['Authorization'], :access_token).call
      end
    end
  end
end

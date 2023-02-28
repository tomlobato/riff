module Riff
  module RequestHandlers
    class Authentication < Base
      private

      def run
        user = authenticate
        @context.set(:user, user) if user
        nil
      end

      def authenticate
        AuthenticateUser.new(@context.headers).call
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Authentication
    class CreateTokens
      def initialize(user)
        @user = user
      end

      def call
        {
          access_token: { token: Authentication::CreateToken.new(@user, :access).call, expires_in: 300 },
          refresh_token: { token: Authentication::CreateToken.new(@user, :refresh).call, expires_in: 900 }
        }
      end
    end
  end
end

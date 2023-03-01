# frozen_string_literal: true

module Riff
  module Authentication
    class UpdateAuthenticationToken
      def initialize(user)
        @user = user
      end

      def call
        @user.update(authentication_token: generate)
      end

      private

      def generate
        loop do
          t = SecureRandom.hex(40)
          break t if @user.class.where(authentication_token: t).none?
        end
      end
    end
  end
end

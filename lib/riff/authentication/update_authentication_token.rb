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
          break t unless user_class.where(authentication_token: t).any?
        end
      end

      def user_class
        @user_class ||= Riff::Settings.instance.get(:user_class)
      end
    end
  end
end

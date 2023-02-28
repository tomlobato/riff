# frozen_string_literal: true

module Riff
  module Authentication
    class CreateToken
      def initialize(user, type)
        @user = user
        @type = type
      end

      def call
        MessageSigner.encode(data: message, expires_at: Time.now + 300, purpose: purpose)
      end
      
      private
      
      def message
        { user_id: @user.id, authentication_token: @user.authentication_token }
      end

      def purpose
        "#{@type}_token".to_sym
      end
    end
  end
end

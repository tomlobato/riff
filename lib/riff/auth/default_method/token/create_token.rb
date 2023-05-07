# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        class CreateToken
          def initialize(user, type)
            @user = user
            @type = type
            @user.user_token ||= create_user_token
          end

          def call
            MessageSigner.encode(data: message, expires_at: Time.now + 300, purpose: purpose)
          end

          private

          def message
            { user_id: @user.id, auth_token: @user.user_token.authentication_token, inpersonator_id: @user.inpersonator_id }
          end

          def purpose
            "#{@type}_token".to_sym
          end

          def create_user_token
            ::SellerToken.new(
              user_id: @user.id,
              inpersonator_id: @user.inpersonator_id,
              authentication_token: Util.generate_authentication_token,
              created_at: Time.now
            ).save_without_log
          end
        end
      end
    end
  end
end

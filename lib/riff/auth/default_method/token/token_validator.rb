# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        class TokenValidator
          def initialize(authorization_token, purpose)
            @message = decode(authorization_token, purpose)
          end

          def call
            raise(Exceptions::AuthFailure) unless valid?

            user.inpersonator_id = @message[:inpersonator_id] if @message[:inpersonator_id]
            user.user_token = user_token
            user
          end

          private

          def decode(authorization_token, purpose)
            MessageSigner.decode(message: authorization_token, purpose: purpose)
          end

          def valid?
            @message && 
              user && 
              user_token && 
              user_token.user_id == user.id &&
              user_token.invalidated_at.nil?
          end

          def user
            @user ||= user_class.where(id: @message[:user_id]).select(*user_fields).first
          end

          def user_class
            Conf.get(:default_auth_user_class)
          end

          def user_fields
            Conf.get(:user_fields)
          end

          def user_token
            ::SellerToken.where(authentication_token: @message[:auth_token]).select(*user_token_fields).first
          end

          def user_token_fields
            Conf.get(:user_token_fields)
          end
        end
      end
    end
  end
end

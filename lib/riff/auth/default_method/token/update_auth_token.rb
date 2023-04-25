# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        class UpdateAuthToken
          def initialize(user)
            @user = user
          end

          def call
            @user.user_token.update(authentication_token: Util.generate_authentication_token, updated_at: Time.now)
          end
        end
      end
    end
  end
end

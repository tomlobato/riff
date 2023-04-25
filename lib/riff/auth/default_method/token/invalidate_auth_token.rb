# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        class InvalidateAuthToken
          def initialize(user)
            @user = user
          end

          def call
            @user.user_token.update(invalidated_at: Time.now)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        class CreateTokens
          def initialize(user)
            @user = user
          end

          def call
            {
              access_token: { token: CreateToken.new(@user, :access).call, expires_in: 300 },
              refresh_token: { token: CreateToken.new(@user, :refresh).call, expires_in: 900 }
            }
          end
        end
      end
    end
  end
end

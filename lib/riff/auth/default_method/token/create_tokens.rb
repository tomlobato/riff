# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        class CreateTokens
          ACCCESS_TOKEN_EXPIRES_IN = 60
          REFRESH_TOKEN_EXPIRES_IN = 3600 * 24 * 30 * 6

          def initialize(user)
            @user = user
          end

          def call
            {
              access_token: {
                token: CreateToken.new(@user, :access, Time.now + ACCCESS_TOKEN_EXPIRES_IN).call,
                expires_in: ACCCESS_TOKEN_EXPIRES_IN
              },
              refresh_token: {
                token: CreateToken.new(@user, :refresh, Time.now + REFRESH_TOKEN_EXPIRES_IN).call,
                expires_in: REFRESH_TOKEN_EXPIRES_IN
              }
            }
          end
        end
      end
    end
  end
end

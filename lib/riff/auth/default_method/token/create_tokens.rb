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
            access_ttl = Conf.access_token_ttl
            refresh_ttl = Conf.refresh_token_ttl

            {
              access_token: {
                token: CreateToken.new(@user, :access, Time.now + access_ttl).call,
                expires_in: access_ttl
              },
              refresh_token: {
                token: CreateToken.new(@user, :refresh, Time.now + refresh_ttl).call,
                expires_in: refresh_ttl
              }
            }
          end
        end
      end
    end
  end
end

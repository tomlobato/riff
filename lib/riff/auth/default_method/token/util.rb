# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        class Util
          MAX_TOKEN_ATTEMPTS = 10

          def self.generate_authentication_token
            MAX_TOKEN_ATTEMPTS.times do
              t = SecureRandom.hex(40)
              return t if Conf.token_class.where(authentication_token: t).blank?
            end
            raise(Exceptions::InternalServerError, "Failed to generate unique token after #{MAX_TOKEN_ATTEMPTS} attempts")
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        class Util
          def self.generate_authentication_token
            loop do
              t = SecureRandom.hex(40)
              break t if ::SellerToken.where(authentication_token: t).none?
            end
          end
        end
      end
    end
  end
end

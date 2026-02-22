# frozen_string_literal: true

require "jwt"

module Riff
  module Auth
    module DefaultMethod
      module Token
        module JwtSigner
          module_function

          ALGORITHM = "HS256"

          def encode(data:, expires_at:, purpose:)
            payload = {
              data: data,
              purpose: purpose.to_s,
              iat: Time.now.to_i
            }
            payload[:exp] = expires_at.to_i if expires_at
            JWT.encode(payload, secret_key, ALGORITHM)
          end

          def decode(message:, purpose:)
            decoded = JWT.decode(message, secret_key, true, { algorithm: ALGORITHM })
            payload = decoded.first
            return unless payload["purpose"] == purpose.to_s

            symbolize(payload["data"])
          rescue JWT::DecodeError => e
            Conf.logger.warn("JwtSigner: decode error — #{e.message}")
            nil
          end

          def secret_key
            ENV.fetch("SECRET_KEY_BASE")
          end

          def symbolize(hash)
            return unless hash.is_a?(Hash)

            hash.transform_keys(&:to_sym)
          end
        end
      end
    end
  end
end

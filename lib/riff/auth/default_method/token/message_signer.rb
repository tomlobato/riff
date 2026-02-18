# frozen_string_literal: true

module Riff
  module Auth
    module DefaultMethod
      module Token
        module MessageSigner
          module_function

          def encode(data:, expires_at:, purpose:)
            verifier.generate(data, expires_at: expires_at, purpose: purpose)
          end

          def decode(message:, purpose:)
            verifier.verify(message, purpose: purpose)
          rescue ActiveSupport::MessageVerifier::InvalidSignature => e
            Conf.logger.warn("MessageSigner: invalid signature — #{e.message}")
            nil
          end

          def verifier
            ActiveSupport::MessageVerifier.new(ENV.fetch("SECRET_KEY_BASE"), digest: "SHA512")
          end
        end
      end
    end
  end
end

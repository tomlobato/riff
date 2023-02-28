# frozen_string_literal: true

module Riff
  module Authentication
    class MessageSigner
      def self.encode(data:, expires_at:, purpose:)
        verifier.generate(data, expires_at: expires_at, purpose: purpose)
      end

      def self.decode(message:, purpose:)
        verifier.verify(message, purpose: purpose)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
      end

      private

      def self.verifier
        ActiveSupport::MessageVerifier.new(ENV['SECRET_KEY_BASE'], digest: 'SHA512')
      end
    end
  end
end

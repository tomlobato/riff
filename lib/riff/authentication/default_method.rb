# frozen_string_literal: true

module Riff
  module Authentication
    class DefaultMethod
      def initialize(context)
        @context = context
      end

      def authenticate
        ::Riff::Authentication::TokenValidator.new(authorization_token, purpose).call
      end

      private

      def purpose
        @context.url.include?("refresh_token") ? :refresh_token : :access_token
      end

      def authorization_token
        @context.headers["Authorization"]
      end
    end
  end
end

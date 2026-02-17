# frozen_string_literal: true

module Riff
  module Session
    class Close
      # DEBUG = true

      def initialize(headers)
        # puts "4 Session close: #{headers.inspect}" if DEBUG
        @headers = headers
      end

      def call
        # puts "4 1 Session close" if DEBUG
        raise(Exceptions::AuthFailure) unless user
        # puts "4 2 Session close" if DEBUG
        Riff::Auth::DefaultMethod::Token::InvalidateAuthToken.new(user).call
        # puts "4 3 Session close" if DEBUG
        Request::Result.new({})
      end

      private

      def user
        # puts "4 4 Session close: '#{@headers["Authorization"]}'" if DEBUG
        @user ||= Riff::Auth::DefaultMethod::Token::TokenValidator.new(@headers["Authorization"], :access_token).call
        # puts "4 5 Session close: '#{@user.inspect}'" if DEBUG
        @user
      end
    end
  end
end

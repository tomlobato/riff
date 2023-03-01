# frozen_string_literal: true

module Riff
  module Session
    class Open
      def initialize(params)
        @params = params
      end

      def call
        validate_params!
        user = user_class.find(username: @params["username"])
        raise(Exceptions::InvalidEmailOrPassword) unless user&.authenticate(@params["password"])

        Request::Result.new(body(user))
      end

      private

      def validate_params!
        msg = {}
        msg[:username] = "is missing" unless @params["username"].present?
        msg[:password] = "is missing" unless @params["password"].present?
        raise(Exceptions::InvalidParams, Oj.dump(msg)) if msg.present?
      end

      def user_class
        Conf.get(:user_class)
      end

      def body(user)
        {
          user: user.values.slice(:id, :name, :email),
          tokens: Authentication::CreateTokens.new(user).call
        }
      end
    end
  end
end

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
        msg = missing_params.compact.to_h
        raise(Exceptions::InvalidParameters, msg.to_json) if msg.present?
      end

      def missing_params
        %w[username password].map do |k|
          [k, "is missing"] if @params[k].blank?
        end
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

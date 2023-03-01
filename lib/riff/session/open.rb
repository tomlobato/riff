module Riff
  module Session
    class Open
      def initialize(params)
        @params = params
      end

      def call
        validate_params!
        user = user_class.find(username: @params['username'])
        raise(Exceptions::InvalidEmailOrPassword) unless user&.authenticate(@params['password'])

        Result.new(body(user))
      end

      private

      def validate_params!
        raise(Exceptions::InvalidParams.new(err_msg)) unless @params['username'].present? && @params['password'].present?
      end

      def err_msg
        msg = {}
        msg[:username] = 'is missing' unless @params['username'].present?
        msg[:password] = 'is missing' unless @params['password'].present?
        Oj.dump(msg)
      end

      def user_class
        Riff::Settings.instance.get(:user_class)
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

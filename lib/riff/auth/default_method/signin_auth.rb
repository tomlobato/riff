module Riff
  module Auth
    module DefaultMethod
      class SigninAuth < SigninAuthMethod
        def request_is_authenticable?
          params['username'].present? && params['password'].present?
        end
  
        def authenticate
          user = user_class.find(username: params['username'])
          raise(Exceptions::InvalidEmailOrPassword) unless user&.authenticate(params['password'])

          user
        end

        private

        def user_class
          Conf.get(:default_auth_user_class)
        end
      end
    end
  end
end

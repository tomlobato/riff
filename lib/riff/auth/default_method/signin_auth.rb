module Riff
  module Auth
    module DefaultMethod
      class SigninAuth < SigninAuthMethod
        def request_is_authenticable?
          params["username"].present? && params["password"].present?
        end

        def authenticate
          user = user_class.where(username: params["username"]).where(extra_clause.to_h).select(*Conf.default_auth_fields).first
          raise(Exceptions::InvalidCredentials) unless user&.authenticate(params["password"])

          user
        end

        private

        def user_class
          Conf.default_auth_user_class
        end

        def extra_clause
          Conf.default_auth_clause
        end
      end
    end
  end
end

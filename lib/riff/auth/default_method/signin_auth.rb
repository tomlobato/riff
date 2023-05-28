module Riff
  module Auth
    module DefaultMethod
      class SigninAuth < SigninAuthMethod
        def request_is_authenticable?
          param_username.present? && param_password.present?
        end

        def authenticate
          user = find_user
          raise(Exceptions::InvalidCredentials) unless user&.authenticate(param_password)

          Conf.on_user&.new(user, :sign_in)&.call if user
          user
        end

        private

        def find_user
          Conf.default_auth_user_class
            .where(Conf.field_username.to_sym => param_username)
            .where(Conf.default_auth_clause.to_h)
            .select(*Conf.default_auth_fields)
            .first
        end

        def param_username
          params[Conf.param_username.to_s]
        end

        def param_password
          params[Conf.param_password.to_s]
        end
      end
    end
  end
end

module Riff
  class OpenSession
    def initialize(params)
      @params = params
    end

    def call
      user = user_class.find(username: @params['username'])
      raise(Exceptions::InvalidEmailOrPassword) unless user&.authenticate(@params['password'])

      Result.new(body(user))
    end

    private

    def user_class
      Riff::Settings.instance.get(:user_class)
    end

    def body(user)
      {
        user: user.values.slice(:id, :name, :email), 
        tokens: tokens(user)
      }
    end

    def tokens(user)
      {
        access_token: { token: Authentication::CreateToken.new(user, :access).call, expires_in: 300 },
        refresh_token: { token: Authentication::CreateToken.new(user, :refresh).call, expires_in: 900 }
      }
    end
  end
end

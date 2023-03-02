# frozen_string_literal: true

# {ApiHelpers} module contains helper methods that are used in the API request specs.
module ApiHelpers
  # It returns the response that our request has returned.
  def response
    last_response
  end

  # It parse the response JSON document into a Ruby data structure and return it.
  def json_response
    JSON.parse(response.body)
  end

  # It generates access token for {User}.
  #
  # @see AccessTokenGenerator
  def access_token(user)
    Riff::Authentication::CreateToken.new(user, :access).call
  end

  # It generates refresh token for {User}.
  #
  # @see RefreshTokenGenerator
  def refresh_token(user)
    Riff::Authentication::CreateToken.new(user, :refresh).call
  end

  def replace_tokens(response)
    response['tokens']['access_token']['token'] = 'authorization_token'
    response['tokens']['refresh_token']['token'] = 'refresh_token'
    response
  end

  def remove_dates(obj)
    obj = obj.dup
    obj.delete('created_at')
    obj.delete('updated_at')
    obj
  end
end

RSpec.configure do |config|
  config.include ApiHelpers
end

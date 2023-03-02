# frozen_string_literal: true

class User < Sequel::Model
  # Plugin that adds BCrypt authentication and password hashing to Sequel models.
  plugin :secure_password

  one_to_many :posts
  many_to_one :company

  def validate
    super

    validates_format(Constants::EMAIL_REGEX, :email) if email
  end
end

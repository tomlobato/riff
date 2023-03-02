# frozen_string_literal: true

class Post < Sequel::Model
  many_to_one :user
  many_to_one :company

  def validate
    super
    validates_presence(%i[body])
  end
end

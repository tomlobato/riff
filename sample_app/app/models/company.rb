# frozen_string_literal: true

class Company < Sequel::Model
  one_to_many :users

  def validate
    super
    validates_presence(%i[name])
  end
end

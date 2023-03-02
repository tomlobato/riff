# frozen_string_literal: true

module Actions
  module User
    class SaveValidator < Dry::Validation::Contract
      params do
        required(:company_id).value(:integer)
        required(:email).value(:string)
        optional(:created_at).value(:time)
        optional(:updated_at).value(:time)
      end

      rule(:email) do
        key.failure('could not be empty') if value.empty?
      end
    end
  end
end

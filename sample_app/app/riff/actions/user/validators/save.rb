# frozen_string_literal: true

module Actions
  module User
    module Validators
      class Save < Dry::Validation::Contract
        params do
          required(:company_id).value(:integer)
          required(:email).value(:string)
        end

        rule(:email) do
          key.failure('could not be empty') if value.empty?
        end
      end
    end
  end
end

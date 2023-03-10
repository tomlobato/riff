# frozen_string_literal: true

module Resources
  module User
    module Validators
      class Update < Dry::Validation::Contract
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

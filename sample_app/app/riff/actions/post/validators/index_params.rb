# frozen_string_literal: true

module Actions
  module Post
    module Validators
      class IndexParams < Dry::Validation::Contract
        params do
          optional(:user_id).value(:integer)
        end

        rule(:user_id) do
          key.failure('must be greater than 0') if value && value < 0
        end
      end
    end
  end
end

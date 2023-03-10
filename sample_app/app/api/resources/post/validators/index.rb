# frozen_string_literal: true

module Resources
  module Post
    module Validators
      class Index < Dry::Validation::Contract
        params do
          optional(:user_id).value(:integer)
        end

        rule(:user_id) do
          key.failure('must be greater than 0') if value&.negative?
        end
      end
    end
  end
end

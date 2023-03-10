# frozen_string_literal: true

module Resources
  module Post
    module Validators
      class Update < Dry::Validation::Contract
        params do
          optional(:body).value(:string)
        end

        rule(:body) do
          key.failure('could not be empty') if value.empty?
        end
      end
    end
  end
end

# frozen_string_literal: true

module Actions
  module Post
    module Validators
      class Save < Dry::Validation::Contract
        params do
          required(:body).value(:string)
        end

        rule(:body) do
          key.failure('could not be empty') if value.empty?
        end
      end
    end
  end
end

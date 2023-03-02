# frozen_string_literal: true

module Actions
  module Post
    class SaveValidator < Dry::Validation::Contract
      params do
        required(:body).value(:string)
        optional(:created_at).value(:time)
        optional(:updated_at).value(:time)
      end

      rule(:body) do
        key.failure('could not be empty') if value.empty?
      end
    end
  end
end

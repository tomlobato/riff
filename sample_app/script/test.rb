# frozen_string_literal: true

class MessageValidator < Dry::Validation::Contract
  params do
    required(:user_id).value(:integer)
    required(:company_id).value(:integer)
    optional(:created_at).value(:time)
    optional(:updated_at).value(:time)
    optional(:body).value(:string)
  end

  rule(:body) do
    key.failure('could not be found') if value.blank?
  end

  rule(:created_at) do
    key.failure('must not be older than 1 month') if value < (Date.today - 30)
  end
end

params = { body: 111, user_id: '2', company_id: 'kk', start_date: Time.current.to_s, created_at: Date.today - 60 }
response = MessageValidator.new.call(params)
puts response
puts response.success?
puts response.errors.to_h

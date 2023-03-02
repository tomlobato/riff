# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    body { 'post body' }

    user
    company
  end
end

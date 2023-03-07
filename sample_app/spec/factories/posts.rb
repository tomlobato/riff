# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    body { 'post body' }
    title { 'post title' }

    user
    company
  end
end

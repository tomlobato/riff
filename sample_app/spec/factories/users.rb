# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test-#{n}@user.com" }
    name { 'John Wayne' }
    sequence(:username) { |n| "john#{n}" }
    password              { 'password'               }
    password_confirmation { 'password'               }
    authentication_token  { SecureRandom.hex(40)     }
    is_admin { true }

    company
  end
end

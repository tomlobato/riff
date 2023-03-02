# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:users) do
      column :id,                   Integer, null: false, primary_key: true, unique: true, auto_increment: true
      column :company_id,           Integer,  null: false
      column :email,                String,   null: false, unique: true
      column :name,                 String,   null: false
      column :username,             String,   null: false, unique: true
      column :is_admin,             TrueClass, null: false, default: false
      column :password_digest,      String,   null: false
      column :authentication_token, String,   null: false, unique: true
      column :created_at,           DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at,           DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end

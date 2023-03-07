# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:posts) do
      column :id,                   Integer,  null: false, primary_key: true, unique: true, auto_increment: true
      column :user_id,              Integer,  null: false
      column :company_id,           Integer,  null: false
      column :body,                 String,   null: false
      column :title,                String,   null: false
      column :created_at,           DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at,           DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end

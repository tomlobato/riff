# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:companies) do
      column :id,                   Integer,  null: false, primary_key: true, unique: true, auto_increment: true
      column :name,                 String,   null: false
      column :created_at,           DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at,           DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end

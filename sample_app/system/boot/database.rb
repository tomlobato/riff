# frozen_string_literal: true

# This file contain code to setup the database connection.

Application.boot(:database) do |container|
  # Load environment variables before setting up database connection.
  use :environment_variables

  init do
    require 'sequel/core'
  end

  start do
    db_url = "mysql2://#{ENV.fetch(
      'DB_SERVER',
      nil
    )}/#{ENV.fetch(
      'DB_NAME',
      nil
    )}?user=#{ENV.fetch('DB_USER', nil)}&password=#{ENV.fetch('DB_PASS', nil)}&encoding=utf8mb4"
    database = Sequel.connect(db_url)

    # Register database component.
    container.register(:database, database)
  end
end

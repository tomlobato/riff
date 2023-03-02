# frozen_string_literal: true

require 'roda'

require_relative './system/boot'

# The main class for Roda Application.
class App < Roda
  # Adds support for handling different execution environments (development/test/production).
  plugin :environments

  # Adds support for heartbeats.
  plugin :heartbeat

  configure :development, :production do
    # A powerful logger for Roda with a few tricks up it's sleeve.
    plugin :enhanced_logger
  end

  # Allows modifying the default headers for responses.
  plugin :default_headers,
         'Content-Type' => 'application/json',
         'Strict-Transport-Security' => 'max-age=16070400;',
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'X-XSS-Protection' => '1; mode=block'

  # Adds request routing methods for all http verbs.
  plugin :all_verbs

  # The json_parser plugin parses request bodies in JSON format if the request's content type specifies JSON.
  # This is mostly designed for use with JSON API sites.
  plugin :json_parser

  # Make request headers available in r.headers
  plugin :request_headers

  route do |r|
    r.post('session', String) do |action|
      Riff.handle_session(r, response, action)
    end

    r.on('actions') do
      Riff.handle_action(r, response)
    end
  end
end

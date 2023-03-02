# frozen_string_literal: true

# This file contains configuration for ActiveSupport module.

Application.boot(:active_support) do
  init do
    require 'active_support'
    require 'active_support/core_ext/object'
    require 'active_support/core_ext/string'
    require 'active_support/json'
    require 'active_support/message_verifier'
  end

  start do
    # Sets the precision of encoded time values to 0.
    ActiveSupport::JSON::Encoding.time_precision = 0
  end
end

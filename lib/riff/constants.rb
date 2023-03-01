# frozen_string_literal: true

module Riff
  module Constants
    ONLY_DIGITS = /^\d+$/.freeze
    UUID = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i.freeze
  end
end

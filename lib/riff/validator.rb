# frozen_string_literal: true

module Riff
  class Validator < Dry::Validation::Contract
    config.messages.backend = :i18n
    config.messages.default_locale = I18n.locale
  end
end

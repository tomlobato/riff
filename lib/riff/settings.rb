# frozen_string_literal: true

module Riff
  class Settings
    # Model

    def model_less
      false
    end

    def model
      nil
    end

    # Select fields

    def default_fields
      nil
    end

    def index_fields
      default_fields
    end

    def show_fields
      default_fields
    end
  end
end

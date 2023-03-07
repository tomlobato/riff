# frozen_string_literal: true

module Actions
  module User
    module Actions
      class CustomMethod < Riff::BaseAction
        def call
          raise(StandardError.new("test error"))
        end
      end
    end
  end
end

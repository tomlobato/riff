# frozen_string_literal: true

module Resources
  module User
    module Actions
      class Delete < Riff::BaseAction
        def call
          Riff::Request::Result.new(1)
        end
      end
    end
  end
end

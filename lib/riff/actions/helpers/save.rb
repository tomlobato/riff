# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      module Save
        private

        def fields
          settings.show_fields || model_class.columns
        end

        def after(rec)
          # may implement
        end
      end
    end
  end
end

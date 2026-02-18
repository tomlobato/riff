# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      module Save
        private

        def fields
          settings.show_fields || model_class.columns
        end

        def response_body(rec)
          if rec.values.keys.sort == fields.sort
            rec.values.slice(*fields)
          else
            @context.model_class.where(id: rec.id).select(*fields).first&.values || {}
          end
        end

        def after(rec)
          # may implement
        end
      end
    end
  end
end

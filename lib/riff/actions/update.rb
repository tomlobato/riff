# frozen_string_literal: true

module Riff
  module Actions
    class Update < Base
      include Helpers::Attributes
      include Helpers::Record
      include Helpers::Save

      def call
        before
        rec = record
        rec.update(attributes)
        after(rec)
        Request::Result.new({ data: response_body(rec) })
      rescue Sequel::ValidationFailed => e
        Exceptions::DbValidationError.raise!(field_errors: Util.record_errors(rec.errors))
      end

      private

      def before
        # may implement
      end

      def response_body(rec)
        if rec.values.keys.sort == fields.sort
          rec.values.slice(*fields)
        else
          @context.model_class.where(id: rec.id).select(*fields).first.values
        end
      end
    end
  end
end

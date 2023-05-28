# frozen_string_literal: true

module Riff
  module Actions
    class Create < Base
      include Helpers::Attributes
      include Helpers::Save

      def call
        rec = nil
        Conf.db.transaction do
          before
          rec = model_class.new(attributes)
          rec.save
          after(rec)
        end
        after_commit(rec)
        Request::Result.new({ data: response_body(rec) || rec.values.slice(*fields) })
      rescue Sequel::ValidationFailed => e
        Exceptions::DbValidationError.raise!(field_errors: Util.record_errors(rec.errors))
      end

      private

      def fields
        settings.show_fields || model_class.columns
      end

      def response_body(rec)
        @context.model_class.where(id: rec.id).select(*fields).first.values if rec.values.keys.sort != fields.sort
      end

      def after(rec)
        # may implement
      end

      def after_commit(rec)
        # may implement
      end

      def before
        # may implement
      end
    end
  end
end

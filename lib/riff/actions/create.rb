# frozen_string_literal: true

module Riff
  module Actions
    class Create < Base
      include Helpers::Attributes
      include Helpers::Save

      def call
        rec = nil
        Application['database'].transaction do
          before
          rec = model_class.new(attributes)
          rec.save
          after(rec)
        end
        after_commit(rec)
        Request::Result.new(response_body(rec) || rec.values.slice(*fields))
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::DbValidationError, Util.record_errors(rec.errors).to_json)
      end

      private

      def fields
        settings.show_fields || model_class.columns
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

      def response_body(rec)
        # may implement
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module DefaultActions
    class Create < Base
      include Helpers::Attributes

      def call
        rec = model_class.new(attributes.merge(extra_attributes.to_h))
        rec.save
        Request::Result.new(rec.values.slice(*fields))
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::DbValidationError, Util.record_errors(rec.errors).to_json)
      end

      private

      def fields
        settings.show_fields || model_class.columns
      end

      def extra_attributes
        # may implement
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module DefaultActions
    class Create < Base
      include Helpers::Attributes
      include Helpers::Save

      def call
        before
        rec = model_class.new(attributes)
        rec.save
        after(rec)
        Request::Result.new(rec.values.slice(*fields))
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
      
      def before
        # may implement
      end
    end
  end
end

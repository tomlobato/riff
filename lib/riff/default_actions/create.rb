# frozen_string_literal: true

module Riff
  module DefaultActions
    class Create < Base
      include Helpers::Attributes

      def call
        a=attributes
        # puts attributes
        rec = model_class.new(a)
        rec.save
        # puts rec.id
        # puts 'rec.values'
        # puts rec.values
        # puts 'rec.values.slice(*fields)'
        # puts rec.values.slice(*fields)
        # puts 'fields'
        # puts fields
        Request::Result.new(rec.values.slice(*fields))
      rescue Sequel::ValidationFailed => e
        # puts 'opss'
        raise(Exceptions::DbValidationError, Util.record_errors(rec.errors).to_json)
      end

      private

      def fields
        settings.show_fields || model_class.columns
      end
    end
  end
end

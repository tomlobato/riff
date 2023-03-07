# frozen_string_literal: true

module Riff
  module DefaultActions
    class Create < Base
      include Helpers::Attributes

      def call
        rec = model_class.new(attributes)
        rec.save
        Request::Result.new(rec.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::DbValidationError, Util.record_errors(rec.errors).to_json)
      end
    end
  end
end

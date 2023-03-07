# frozen_string_literal: true

module Riff
  module DefaultActions
    class Update < Base
      include Helpers::Attributes
      include Helpers::Record

      def call
        rec = record
        rec.update(attributes)
        Request::Result.new(rec.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::DbValidationError, Util.record_errors(rec.errors).to_json)
      end
    end
  end
end

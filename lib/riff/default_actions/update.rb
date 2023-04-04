# frozen_string_literal: true

module Riff
  module DefaultActions
    class Update < Base
      include Helpers::Attributes
      include Helpers::Record
      include Helpers::Save

      def call
        before
        rec = record
        rec.update(attributes)
        after(rec)
        Request::Result.new(rec.values.slice(*fields))
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::DbValidationError, Util.record_errors(rec.errors).to_json)
      end

      private

      def before
        # may implement
      end
    end
  end
end

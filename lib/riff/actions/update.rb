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
      rescue Sequel::ValidationFailed
        Exceptions::DbValidationError.raise!(field_errors: Util.record_errors(rec.errors))
      end

      private

      def before
        # may implement
      end
    end
  end
end

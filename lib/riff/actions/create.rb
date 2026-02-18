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
        Request::Result.new({ data: response_body(rec) })
      rescue Sequel::ValidationFailed
        Exceptions::DbValidationError.raise!(field_errors: Util.record_errors(rec&.errors))
      end

      private

      def after_commit(rec)
        # may implement
      end

      def before
        # may implement
      end
    end
  end
end

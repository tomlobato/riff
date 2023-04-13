# frozen_string_literal: true

module Riff
  module Actions
    class Show < Base
      include Helpers::Record

      def call
        Request::Result.new(body)
      end

      private

      def body
        rec = record(fields)
        rec&.values.merge(extra_fields(rec).to_h)
      end

      def fields
        settings.show_fields
      end

      def extra_fields(rec)
        # may implement
      end
    end
  end
end

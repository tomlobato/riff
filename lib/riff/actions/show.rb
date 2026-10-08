# frozen_string_literal: true

module Riff
  module Actions
    class Show < Base
      include Helpers::Record
      include Helpers::Common

      def call
        Request::Result.new({ data: body })
      end

      private

      def body
        rec = record
        rec&.values&.merge(extra_fields(rec).to_h)
      end

      def select
        parse_fields(settings.show_fields) || model_class.columns
      end

      def extra_fields(rec)
        # may implement
      end
    end
  end
end

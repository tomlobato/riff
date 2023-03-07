# frozen_string_literal: true

module Riff
  module DefaultActions
    class Show < Base
      include Helpers::Record

      def call
        Request::Result.new(body)
      end

      private

      def body
        record(fields)&.values
      end

      def fields
        settings.show_fields
      end
    end
  end
end

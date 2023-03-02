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
        record&.values
      end
    end
  end
end

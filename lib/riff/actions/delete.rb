# frozen_string_literal: true

module Riff
  module Actions
    class Delete < Base
      include Helpers::Record

      def call
        record.delete
        Request::Result.new
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module DefaultActions
    class Update < Base
      include Helpers::Attributes
      include Helpers::Record

      def call
        record.update(attributes)
        Request::Result.new(record.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::DbValidationError, e.message.to_json)
      end
    end
  end
end

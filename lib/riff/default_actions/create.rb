# frozen_string_literal: true

module Riff
  module DefaultActions
    class Create < Base
      include Helpers::Attributes

      def call
        record = model_class.create(attributes)
        Request::Result.new(record.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::DbValidationError, e.message.to_json)
      end
    end
  end
end

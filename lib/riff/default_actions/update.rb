# frozen_string_literal: true

module Riff
  module DefaultActions
    class Update < Base
      def call
        record.update(@context.params)
        Request::Result.new(record.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::SequelInvalidParams, e.message.to_json)
      end
    end
  end
end

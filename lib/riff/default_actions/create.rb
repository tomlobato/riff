# frozen_string_literal: true

module Riff
  module DefaultActions
    class Create < Base
      def call
        record = model_klass.create(@context.params)
        Request::Result.new(record.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::SequelInvalidParams, e.message.to_json)
      end
    end
  end
end

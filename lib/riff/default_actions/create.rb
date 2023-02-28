module Riff
  module DefaultActions
    class Create < Base
      def call
        record = model_klass.create(@context.params)
        Result.new(record.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::SequelInvalidParams.new(e.message.to_json))
      end
    end
  end
end

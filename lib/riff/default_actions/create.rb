module Riff
  module DefaultActions
    class Create < Base
      def call
        record = model_klass.create(@context.params)
        Result.new(record.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::InvalidParams.new(e.message))
      end
    end
  end
end

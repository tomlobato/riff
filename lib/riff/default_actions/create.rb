module Riff
  module DefaultActions
    class Create < Base
      def call
        record = model_klass.create(@context.params)
        Result.new(record.values)
      end
    end
  end
end

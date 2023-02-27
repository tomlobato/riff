module Riff
  module DefaultActions
    class Update < Base
      def call
        record.update(@context.params)
        Result.new(record.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::InvalidParams.new(e.message))
      end
    end
  end
end

module Riff
  module DefaultActions
    class Update < Base
      def call
        record.update(@context.params)
        Result.new(record.values)
      rescue Sequel::ValidationFailed => e
        raise(Exceptions::SequelInvalidParams.new(e.message.to_json))
      end
    end
  end
end

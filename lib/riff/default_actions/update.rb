module Riff
  module DefaultActions
    class Update < Base
      def call
        record.update(@context.params)
        Result.new(record.values)
      end
    end
  end
end

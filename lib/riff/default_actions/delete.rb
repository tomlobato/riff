module Riff
  module DefaultActions
    class Delete < Base
      def call
        record.delete
        Result.new
      end
    end
  end
end

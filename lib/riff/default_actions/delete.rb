module Riff
  module DefaultActions
    class Delete < Base
      def call
        record.delete
        Request::Result.new
      end
    end
  end
end

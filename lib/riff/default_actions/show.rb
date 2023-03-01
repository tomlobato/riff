module Riff
  module DefaultActions
    class Show < Base
      def call
        body = record&.values
        Request::Result.new(body)
      end
    end
  end
end

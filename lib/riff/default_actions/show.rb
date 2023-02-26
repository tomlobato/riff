module Riff
  module DefaultActions
    class Show < Base
      def call
        model_klass[@context.id]&.values
      end
    end
  end
end

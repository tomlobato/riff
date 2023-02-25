module Riff
  module DefaultActions
    class Update < Base
      def call
        object.update(@context.params)
      end

      def object
        model_klass[@context.id]
      end
    end
  end
end

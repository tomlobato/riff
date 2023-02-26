module Riff
  module DefaultActions
    class Delete < Base
      def call
        object.delete
      end

      def object
        model_klass[@context.id]
      end
    end
  end
end

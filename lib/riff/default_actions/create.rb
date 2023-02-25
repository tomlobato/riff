module Riff
  module DefaultActions
    class Create < Base
      def call
        model_klass.create(@context.params)
      end
    end
  end
end

module Riff
  module DefaultActions
    class Base
      def initialize(context)
        @context = context
      end

      def call
        raise('must implement!')
      end

      private

      def model_klass
        @context.model_name.constantize
      end
    end
  end
end

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

      def record
        r = model_klass[@context.id]
        raise(Riff::Exceptions::ResourceNotFound) unless r

        r
      end
    end
  end
end

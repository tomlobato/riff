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
        model_klass[@context.id] || raise(record_not_found)
      end

      def record_not_found
        Riff::Exceptions::ResourceNotFound.new("unable to find #{@context.resource} with id '#{@context.id}'")
      end
    end
  end
end

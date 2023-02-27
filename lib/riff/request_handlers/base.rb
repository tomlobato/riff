module Riff
  module RequestHandlers
    class Base
      extend Forwardable
      def_delegators :@context, :model_name, :action_class_name, :action

      def initialize(next_handler, context)
        @next_handler = next_handler
        @context = context
        setup
      end

      def handle
        run || handle_next
      end

      private

      def handle_next
        @next_handler.handle if @next_handler
      end

      def run
        raise('must implement!')      
      end

      def setup
        # may implement
      end
    end
  end
end

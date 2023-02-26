module Riff
  module RequestHandlers
    class Base
      def initialize(next_handler, context)
        @next_handler = next_handler
        @context = context
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
    end
  end
end

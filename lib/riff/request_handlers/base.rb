module Riff
  module RequestHandlers
    class Base
      def initialize(next_handler)
        @next_handler = next_handler
      end

      def handle(context)
        @context = context
        run || handle_next
      end

      private

      def handle_next
        @next_handler.handle(@context) if @next_handler
      end

      def run
        raise('must implement!')      
      end
    end
  end
end

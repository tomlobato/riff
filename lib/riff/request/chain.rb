# frozen_string_literal: true

module Riff
  module Request
    class Chain
      HANDLERS = [
        RequestHandlers::Auth,
        RequestHandlers::Authorization,
        RequestHandlers::CheckParams,
        RequestHandlers::Action
      ].freeze

      def initialize(context)
        @context = context
      end

      def call
        bind_handlers.handle
      end

      private

      def bind_handlers
        next_handler = nil
        HANDLERS.reverse.each do |handler_class|
          next_handler = handler_class.new(next_handler, @context)
        end
        next_handler
      end
    end
  end
end

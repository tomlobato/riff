# frozen_string_literal: true

module Riff
  module RequestHandlers
    class Action < Base
      private

      def run
        action_class.new(@context).call
      end

      def action_class
        @context.get(:action_class)
      end
    end
  end
end

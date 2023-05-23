# frozen_string_literal: true

module Riff
  module RequestHandlers
    class Action < Base
      private

      def run
        action_instance = action_class.new(@context)
        action_instance.call
      rescue StandardError => e
        e.message ||= action_instance&.error_msg.presence
        raise
      end

      def action_class
        @context.get(:action_class)
      end
    end
  end
end

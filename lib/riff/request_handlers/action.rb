# frozen_string_literal: true

module Riff
  module RequestHandlers
    class Action < Base
      private

      def run
        action_instance = action_class.new(@context)
        action_instance.call
      rescue StandardError => e
        if e.is_a?(Riff::Exceptions::RiffError)
          riff_error = e
        else
          Util.log_error(e)
          riff_error = Riff::Exceptions::RescuedActionError.new(e.message)
          riff_error.set_backtrace(e.backtrace)
        end
        riff_error.display_msg ||= action_instance&.error_msg.presence
        riff_error.icon ||= action_instance&.error_icon.presence
        raise(riff_error)
      end

      def action_class
        @context.action_class
      end
    end
  end
end

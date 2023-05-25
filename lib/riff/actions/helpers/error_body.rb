# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      class ErrorBody
        def initialize(msg, icon)
          @msg = msg
          @icon = icon
        end

        def call
          case @msg
          when NilClass
            ""
          when String
            { msg: { text: @msg, type: "error", **icon.to_h } }
          when Hash
            { msg: @msg }
          else
            raise(Riff::Exceptions::InvalidResponseBody, "Unhandled body class '#{@msg.class}'")
          end
        end

        private

        def icon
          { icon_left: Icon.new(@icon, false).call } if @icon
        end
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      class SuccessBody
        KEYS = { body: :data, meta: :meta, extra: :extra }.freeze

        def initialize(body, msg, icon, meta, extra)
          @body = body
          @msg = msg
          @icon = icon
          @meta = meta
          @extra = extra
        end

        def call
          ret = KEYS.map do |k, output_k|
            v = instance_variable_get("@#{k}")
            [output_k, v] if v.present?
          end.compact.to_h

          if @msg.present?
            ret[:msg] = msg_body
            ret[:msg][:icon] = Icon.new(@icon, true).call if @icon.present?
          end

          ret
        end

        private

        def msg_body
          case @msg
          when String
            { text: @msg, type: "success" }
          when Hash
            @msg
          else
            raise(Riff::Exceptions::InvalidResponseBody, "Unhandled body class '#{@msg.class}'")
          end
        end
      end
    end
  end
end

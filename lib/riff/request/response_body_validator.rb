# frozen_string_literal: true

module Riff
  module Request
    class ResponseBodyValidator
      ROOT_KEYS = {
        success: [TrueClass, FalseClass],
        data: [Hash, Array, String],
        msg: Hash,
        meta: Hash,
        extra: Hash
      }.freeze

      MSG_KEYS = {
        title: String,
        text: String,
        detail: String,
        links: [String, Array],
        type: String,
        view_type: String,
        view_options: Hash,
        fields: Hash
      }.freeze

      VIEW_OPTIONS_KEYS = {
        timeout: Integer,
        color: String,
        background: String,
        allow_close: [TrueClass, FalseClass],
        close_on_tap: [TrueClass, FalseClass]
      }.freeze

      MSG_TYPES = ["success", "error", "warning", "info"].freeze
      MSG_VIEW_TYPES = ["toast", "modal", "alert", "notification", "inline"].freeze

      def initialize(body)
        @body = body
      end

      def call
        Riff::HashValidator.new(@body, ROOT_KEYS).call!
        if (msg = @body[:msg])
          Riff::HashValidator.new(msg, MSG_KEYS).call! if msg
          raise(ArgumentError, "msg.type must be one of: #{MSG_TYPES.joni(', ')}.") if msg[:type] && !msg[:type].in?(MSG_TYPES)
          raise(ArgumentError, "msg.view_type must be one of: #{MSG_VIEW_TYPES.joni(', ')}.") if msg[:view_type] && !msg[:view_type].in?(MSG_VIEW_TYPES)

          if (view_options = msg[:view_options])
            Riff::HashValidator.new(view_options, VIEW_OPTIONS_KEYS).call! 
            raise(ArgumentError, "msg.view_options.timeout must be greater than 0.") if view_options[:timeout] && view_options[:timeout] <= 0
          end
        end
      end
    end
  end
end

# spec:
# 
# {
#   success: true,
#   data: <anything>,
#   msg: {
#     title: "string",
#     text: "string",
#     detail: "string",
#     links: "string",
#     type: "success" || "error" || "warning" || "info",
#     view_type: "toast" || "modal" || "alert" || "notification" || "inline",
#     view_options: {timeout: 5000, color: "$color", background: "$color", allow_close: true, close_on_tap: true}
#     fields: {
#       field: ["string", "string"],
#       field: ["string", "string"]
#     }
#   },
#   meta: {
#     pagination: {
#       total: 1,
#       per_page: 1,
#       current_page: 1,
#       total_pages: 1
#     }
#    }
#   extra: {
#     x: "string",
#     y: "string",
#     ...
#   }
# }

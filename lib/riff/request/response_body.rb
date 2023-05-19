module Riff
  module Request
    class ResponseBody
      FIELDS = %i[success data msg meta extra].freeze

      def initialize(body, status, content_type)
        # puts "body: #{body.inspect}"
        @body = check_body(body)
        @status = status
        @content_type = content_type
      end

      def call
        @body.is_a?(String) ? @body : brush_body(@body)
      end

      private

      def brush_body(raw)
        # puts "raw: #{raw.inspect}"
        raw[:success] = success
        cleanup!(raw)
        result_body(raw)
      end

      def cleanup!(raw)
        FIELDS.each do |field|
          next if field == :success

          raw.delete(field) unless raw[field].present?
        end
      end

      def success
        @status.nil? || @status < 400
      end

      def result_body(raw)
        case @content_type
        when 'application/json'
          raw.presence&.to_json
        when 'application/xml', 'text/xml'
          raw.presence&.to_xml
        else
          raw.presence
        end
      end

      def check_body(raw)
        case raw
        when String, Array, Hash
          raw
        when NilClass
          ''
        else
          raise(Riff::Exceptions::InvalidResponseBody, "Unhandled body class '#{raw.class}'")
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

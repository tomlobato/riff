# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      module ResultBuilder
        def redirect_permanent(location)
          redirect(location, 301)
        end

        def redirect_temporary(location)
          redirect(location, 302)
        end

        def redirect(location, status)
          Request::Result.new(nil, headers: { "Location" => location }, status: status)
        end

        # def json(body, raw: false)
        #   body[:data] = body unless raw || body.is_a?(String)
        #   Request::Result.new(body, content_type: "application/json")
        # end

        # def xml(body, raw: false)
        #   body[:data] = body unless raw || body.is_a?(String)
        #   Request::Result.new(body, content_type: "application/xml")
        # end

        # def html(body)
        #   Request::Result.new(body, content_type: "text/html")
        # end

        # def text(body)
        #   Request::Result.new(body, content_type: "text/plain")
        # end

        # def success(body = nil, data = {})
        #   if body.present?
        #     body = { data: body } 
        #   else
        #     body = {}
        #   end

        #   if data[:msg].present?
        #     if data[:msg].is_a?(String)
        #       body[:msg] = { text: data[:msg], type: "success" } 
        #     else
        #       body[:msg] = data[:msg]
        #     end
        #   end

        #   body[:meta] = data[:meta] if data[:meta].present?

        #   extra_keys = data.keys - %i[msg meta]
        #   body[:extra] = data.slice(*extra_keys) if extra_keys.present?

        #   Request::Result.new(body)
        # end

        # def error(body)
        #   Request::Result.new(body, status: 500)
        # end

        def result(body = nil, content_type: nil, headers: nil, status: nil)
          Request::Result.new(body, content_type: content_type, headers: headers, status: status)
        end

        # 
        # Method success(body = nil, msg: nil, body_mode: nil)
        # 

        # body: 
          # Hash/Array/String: sent in data field
          # NilClass: data field will be empty

        # msg:
          # String: sent in msg.text field
          # Hash: sent in msg field
          # NilClass: msg field will be empty

        # body_mode: 
          # :data: body will be mapped to data field (default)
          # :raw: body will be mapped to full response body

        # status:
          # Integer: HTTP status code (default: 200)

        # Examples:
        # success() -> { success: true }
        # success(msg: 'great, it worked') -> { msg: { text: 'great, it worked' }, success: true }
        # success({...}) -> { data: {...}, success: true }
        # success({...}, body_mode: :raw) -> {...}
        # success({...}, msg: 'it worked') -> { data: {...}, msg: { text: 'it worked' }, success: true }
        # success({msg: { text: 'it worked, nut...', type: 'warning'}}) -> { msg: { text: 'it worked, nut...', type: 'warning' }, success: true }
  
        def success(body = nil, msg: nil, meta: nil, extra: nil, body_mode: nil, status: 200)
          body = build_success_body(body, msg, meta, extra) unless body_mode == :raw
          Riff::Request::Result.new(body, status: status)
        end

        # 
        # Method error(msg = nil)
        # 

        # msg: 
          # String: sent in msg.text field
          # Hash: sent in msg field
          # NilClass: msg field will be empty

        # status:
          # Integer: HTTP status code (default: 422)

        # Examples:
        # error() -> { success: false }
        # error('ops, it didn`t work') -> { msg: { text: 'ops, it didn`t work' }, success: false }
        # error({...}) -> { msg: {...}, success: false }
  
        def error(msg = nil, status: 422)
          Riff::Request::Result.new(build_error_body(msg), status: status)
        end

        private

        def build_success_body(body, msg, meta, extra)
          ret = {}
          ret[:data] = body if body.present?
          ret[:msg] = build_success_msg_body(msg) if msg.present?
          ret[:meta] = meta if meta.present?
          ret[:extra] = extra if extra.present?
          ret
        end

        def build_success_msg_body(msg)
          case msg
          when String
            { text: msg, type: 'success' }
          when Hash
            msg
          else
            raise(Riff::Exceptions::InvalidResponseBody, "Unhandled body class '#{msg.class}'")
          end
        end

        def build_error_body(msg)
          case msg
          when NilClass
            ''
          when String
            { msg: { text: msg, type: 'error' } }
          when Hash
            { msg: msg }
          else
            raise(Riff::Exceptions::InvalidResponseBody, "Unhandled body class '#{msg.class}'")
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

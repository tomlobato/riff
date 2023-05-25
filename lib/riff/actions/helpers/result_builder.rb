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

        def result(body = nil, body_mode: nil, content_type: nil, headers: nil, status: nil)
          body = { data: body } unless body_mode == :raw
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
  
        def success(body = nil, body_mode: nil, msg: nil, icon: false, meta: nil, extra: nil, status: 200)
          body = SuccessBody.new(body, msg, icon, meta, extra).call unless body_mode == :raw
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
  
        def error(body = nil, icon: false, body_mode: nil, status: 422)
          body = ErrorBody.new(body, icon).call unless body_mode == :raw
          Riff::Request::Result.new(body, status: status)
        end
      end
    end
  end
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


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

        def success(body = nil, body_mode: nil, msg: nil, icon: false, meta: nil, extra: nil, status: 200)
          body = SuccessBody.new(body, msg, icon, meta, extra).call unless body_mode == :raw
          Riff::Request::Result.new(body, status: status)
        end

        def error(body = nil, icon: false, body_mode: nil, status: 422)
          body = ErrorBody.new(body, icon).call unless body_mode == :raw
          Riff::Request::Result.new(body, status: status)
        end
      end
    end
  end
end

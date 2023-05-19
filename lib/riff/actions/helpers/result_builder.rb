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

        def json(body, raw: false)
          body[:data] = body unless raw || body.is_a?(String)
          Request::Result.new(body, content_type: "application/json")
        end

        def xml(body, raw: false)
          body[:data] = body unless raw || body.is_a?(String)
          Request::Result.new(body, content_type: "application/xml")
        end

        def html(body, raw: false)
          Request::Result.new(body, content_type: "text/html")
        end

        def text(body, raw: false)
          Request::Result.new(body, content_type: "text/plain")
        end

        def success(body = nil)
          body = { data: body } if body.present?
          Request::Result.new(body)
        end
      end
    end
  end
end

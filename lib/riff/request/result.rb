# frozen_string_literal: true

module Riff
  module Request
    class Result
      attr_reader :body, :content_type, :headers, :status

      def self.redirect_permanent(location)
        redirect(location, 301)
      end

      def self.redirect_temporary(location)
        redirect(location, 302)
      end

      def self.redirect(location, status)
        new(nil, headers: { "Location" => location }, status: status)
      end

      def initialize(body = nil, content_type: nil, headers: nil, status: nil)
        @body = check_body(body)
        @content_type = content_type
        @headers = headers
        @status = status
      end

      private

      def check_body(raw)
        case raw
        when String
          raw
        when NilClass
          ""
        when Array, Hash
          raw.to_json
        else
          raise(Riff::Exceptions::InvalidResponseBody, "Unhandled body class '#{raw.class}'")
        end
      end
    end
  end
end

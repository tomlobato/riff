# frozen_string_literal: true

module Riff
  module Request
    class Result
      attr_reader :body, :content_type, :headers, :status

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

# frozen_string_literal: true

module Riff
  module Request
    class Result
      attr_reader :body, :content_type, :headers, :status

      def initialize(body = nil, content_type: nil, headers: nil, status: nil)
        @body = body
        @content_type = content_type
        @headers = headers
        @status = status
      end
    end
  end
end

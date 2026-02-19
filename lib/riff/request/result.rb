# frozen_string_literal: true

module Riff
  module Request
    class Result
      FALLBACK_CONTENT_TYPE = "application/json"

      attr_reader :body, :content_type, :headers, :status

      def initialize(body = nil, content_type: nil, headers: {}, status: nil)
        @headers = headers
        @status = status
        select_content_type(content_type)
        @body = prepare_body(body)
      end

      private

      def select_content_type(content_type)
        if content_type.present? && header_content_type.present?
          raise(
            Riff::Exceptions::ContentTypeAlreadySet,
            "Content-Type already set to '#{header_content_type}' in headers parameter."
          )
        end

        @headers["Content-Type"] = content_type.presence || Conf.default_content_type || FALLBACK_CONTENT_TYPE
      end

      def header_content_type
        @headers["Content-Type"]
      end

      def prepare_body(body)
        return "" unless body

        if body.is_a?(Hash)
          body = body.reject { |_k, v| v.blank? && v != false && !v.is_a?(Array) }
        end
        body.merge(success: success?)
      end

      def success?
        return @success if defined?(@success)

        @success = @status.nil? || @status < 400
      end
    end
  end
end

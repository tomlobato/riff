# frozen_string_literal: true

module Riff
  module Request
    class Result
      DEFAULT_CONTENT_TYPE = 'application/json'.freeze

      attr_reader :body, :content_type, :headers, :status

      def initialize(body = nil, content_type: nil, headers: nil, status: nil)
        select_content_type(content_type)
        @body = ResponseBody.new(body, status, header_content_type).call
        @headers = headers
        @status = status
      end

      private

      def select_content_type(content_type)
        if content_type.present? && header_content_type.present?
          raise(Riff::Exceptions::ContentTypeAlreadySet, "Content-Type already set to '#{header_content_type}' in headers parameter.")
        end
        @headers ||= {}
        @headers['Content-Type'] = content_type.presence || Conf.get(:default_content_type) || DEFAULT_CONTENT_TYPE
      end

      def header_content_type
        @headers['Content-Type']
      end
    end
  end
end

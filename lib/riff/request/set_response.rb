# frozen_string_literal: true

module Riff
  module Request
    class SetResponse
      def initialize(response, result)
        @response = response
        @result = result
      end

      def call
        content_type
        headers
        status
        @result.body
      end

      private

      def content_type
        @response["Content-Type"] = @result.content_type if @result.content_type
      end

      def headers
        @result.headers&.each { |k, v| @response[k] = v }
      end

      def status
        @response.status = @result.status if @result.status
      end
    end
  end
end

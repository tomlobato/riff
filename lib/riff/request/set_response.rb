# frozen_string_literal: true

module Riff
  module Request
    class SetResponse
      def initialize(response, result)
        @response = response
        @result = result
      end

      def call
        check_body!
        content_type
        headers
        status
        serialize(@result.body)
      end

      private

      def check_body!
        Riff::Request::ResponseBodyValidator.new(@result.body).call if @result.body && !@result.body.is_a?(String)
      end

      def content_type
        @response["Content-Type"] = @result.content_type if @result.content_type
      end

      def headers
        @result.headers&.each { |k, v| @response[k] = v }
      end

      def status
        @response.status = @result.status if @result.status
      end

      def serialize(raw)
        case @response["Content-Type"]
        when "application/json"
          raw.presence&.to_json
        when "application/xml", "text/xml"
          raw.presence&.to_xml
        else
          raw
        end
      end
    end
  end
end

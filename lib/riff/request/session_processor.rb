# frozen_string_literal: true

module Riff
  module Request
    class SessionProcessor
      def initialize(request, response, type)
        @request = request
        @response = response
        @type = type
      end

      def call
        SetResponse.new(@response, sign_in_out).call
      end

      private

      def sign_in_out
        call_session
      rescue StandardError => e
        desc, status = HandleError.new(e).call
        Result.new(desc, status: status)
      end

      def call_session
        case @type
        when "login"
          Session::Open.new(@request.params).call
        when "logout"
          Session::Close.new(@request.headers).call
        when "refresh"
          Session::Refresh.new(@request.headers).call
        else
          raise(invalid_request_path)
        end
      end

      def invalid_request_path
        Exceptions::InvalidRequestPath.new("'#{@type}' is not a valid session action")
      end
    end
  end
end

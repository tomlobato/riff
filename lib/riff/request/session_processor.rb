# frozen_string_literal: true

module Riff
  module Request
    class SessionProcessor
      ACTIONS = { login: "login", logout: "logout", refresh: "refresh" }

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
        Util.log_error(e) unless e.is_a?(Riff::Exceptions::RiffError)
        desc, status = HandleError.new(e).call
        Result.new(desc, status: status)
      end

      def call_session
        case @type
        when ACTIONS[:login]
          Session::Open.new(@request).call
        when ACTIONS[:logout]
          Session::Close.new(@request.headers).call
        when ACTIONS[:refresh]
          Session::Refresh.new(@request.headers).call
        else
          raise(invalid_request_path)
        end
      end

      def invalid_request_path
        msg = "'#{@type}' is not a valid session action. Expected actions: #{ACTIONS.values.join(", ")}."
        Exceptions::InvalidRequestPath.new(msg)
      end
    end
  end
end
